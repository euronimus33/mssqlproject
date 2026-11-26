WITH dbcpu
as
(
	select		pa.dbid
				,db_name(pa.dbid) as db
				,sum(qs.total_worker_time/1000) as [cputime]
	from		sys.dm_exec_query_stats qs with (nolock)
	cross apply 
	(
		select	convert(int, value) as [dbid]
		from	sys.dm_exec_plan_attributes(qs.plan_handle)
		where	attribute = N'dbid'
	)	as pa
	group by	pa.dbid
)
select		db 
			,cputime as [cpu time (ms)]
			,convert(decimal(5,2), 1. * [cputime] / sum([cputime]) over () * 100) as [cpu percent]
from		dbcpu
where		dbid <> 32767 --resoursedb
order by	cputime desc


