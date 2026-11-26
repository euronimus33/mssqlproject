select  
			er.session_id 
			,er.request_id
			,db_name(er.database_id) as [database]
			,er.start_time
			,convert(decimal(21,3), er.total_elapsed_time / 1000.) as [duration]
			,er.cpu_time 
			,substring(qt.text, (er.statement_start_offset /2) + 1, (( 
																		case er.statement_end_offset
																			when -1 then datalength(qt.text)
																			else er.statement_end_offset
																		end - er.statement_start_offset
																	  ) / 2
																	) + 1 ) as [statement]
			,er.status
			,er.wait_type
			,er.wait_time
			,er.blocking_session_id
			,er.last_wait_type
			,er.reads 
			,er.logical_reads
			,er.writes
			,er.granted_query_memory
			,er.dop 
			,er.row_count 
			,er.percent_complete
			,es.login_time
			,es.original_login_name
			,es.host_name
			,es.program_name
			,c.client_net_address
			,ib.event_info as [buffer]
			,qt.text as [sql]
			,try_convert(xml, p.query_plan) as [query_plan]
from		sys.dm_exec_requests er with (nolock)
outer apply sys.dm_exec_input_buffer(er.session_id, er.request_id)	ib
outer apply sys.dm_exec_sql_text(er.sql_handle) qt
outer apply	sys.dm_exec_text_query_plan(er.plan_handle, er.statement_start_offset, er.statement_end_offset) p
left join	sys.dm_exec_connections c with (nolock)
	on		er.session_id = c.session_id 
left join	sys.dm_exec_sessions es with (nolock)
	on		er.session_id = es.session_id
where		er.status <> 'background' and er.session_id  > 50
order by	er.cpu_time desc
option		(recompile, maxdop 1)