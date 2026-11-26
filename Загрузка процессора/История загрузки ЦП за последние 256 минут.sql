-- Загрузка процессора за последние 


--select * from sys.dm_os_sys_info 
--select * from sys.dm_os_ring_buffers

declare @now bigint;

select @now = cpu_ticks / ( cpu_ticks / ms_ticks )--1 055 963,
from sys.dm_os_sys_info with (nolock)

;with ring_buffer_data([timestamp], rec)
	as 
(
	select	[timestamp]
			,convert(xml, record) as rec
	from	sys.dm_os_ring_buffers with (nolock)
	where	ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' and 
			record like N'%<SystemHealth>%'
)
, data(id, sytem_idle, sql_cpu, [timestamp])
	as
(
	select	rec.value('(./Record/@id)[1]', 'int')
			,rec.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','int')
			,rec.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int')
			,[timestamp] 
	FROM	ring_buffer_data
)
select		top 360 dateadd(MS, -1 * (@now - [timestamp]), getdate()) as [event time]
			,sql_cpu as [sql server cpu utilization]
			,sytem_idle as [sytem_idle]
			,100 - sytem_idle - sql_cpu as [other processes cpu utilization]
from		data
order by id desc
option (recompile, maxdop 1);