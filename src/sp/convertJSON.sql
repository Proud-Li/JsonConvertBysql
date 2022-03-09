IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[convertJSON]') AND type in (N'P')) 
drop Procedure [dbo].[convertJSON]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
******************************************************************************************
Author:     PD
Date:       20220304
Note:       JSON->Hierarchy->Table 包含 行列转换
1效率不高 不要用在生产环境
2数字字段 不要有null 不然只能处理成字符

Modified history
-----------------
Date			Modifier		Task			Remark
----------		---------		-----------		---------------------------------

desc
******************************************************************************************

--从缓冲池中删除所有清除缓冲区。
dbcc dropcleanbuffers
--从过程缓存中删除所有元素。
dbcc freeproccache

*/

CREATE PROCEDURE [dbo].[convertJSON]
(
	@JSON NVARCHAR(MAX)
	,@NAME NVARCHAR(200)=''			
	,@Success BIT=1 OUTPUT		    --
	,@Msg NVARCHAR(MAX)='' OUTPUT	--
	,@Debug CHAR(1)='0'		    	--
)
AS
BEGIN

	SET NOCOUNT ON

	SELECT @Success=0,@Msg=''
    declare @sql nvarchar(max)
    select @sql=''
    
    
	BEGIN TRY

	    declare @tmp1 Hierarchy

        select * into #tmp2
        from @tmp1 a

	    insert into @tmp1
		    (element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType)
	    select a.element_id,a.sequenceNo,a.parent_ID,a.[Object_ID],a.[NAME],a.StringValue,a.ValueType
	    from dbo.parseJSON(@json) a

	 

	    insert into #tmp2
		    (element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType)
	    select a.element_id,a.sequenceNo,a.parent_ID,a.[Object_ID],a.[NAME],a.StringValue,a.ValueType
	    from @tmp1 a
	    left join @tmp1 b on a.parent_ID=b.[Object_ID]
	    left join @tmp1 c on b.parent_ID=c.[Object_ID]
	    where c.[NAME]=@NAME
 

        select *
        into #tmp_name
        from (
            select a.NAME,ValueType=max(a.ValueType),element_id=max(a.element_id)
            from #tmp2 a 
            group by a.NAME
        )a
        order by a.element_id


        --if @Debug=1 select * from #tmp_name

	    select @sql="
		    select a.parent_ID"
	    select @sql=@sql+"
			    ,"
                +"max(case when a.[NAME]='"+a.[NAME]+"' then "
                + case a.ValueType
                    when 'string' then "nullif(a.StringValue,'null')"
                    when 'int' then "convert("+a.ValueType+",a.StringValue)"
                    when 'bigint' then "convert("+a.ValueType+",a.StringValue)"
                    when 'dec(18,6)' then "convert("+a.ValueType+",a.StringValue)"
                    when 'dec(26,12)' then "convert("+a.ValueType+",a.StringValue)"
                    else "nullif(a.StringValue,'null')" end
                    --else "a.StringValue" end
                +" else null end)" 
                +" as ["+a.[NAME]+"]" 
	    from #tmp_name a  

	    set @sql = @sql +"
		    from #tmp2 a   
		    group by a.parent_ID 
		    "

	    print(@sql)  

	    --select sqlxml=convert(xml,@sql)
	    exec(@sql)


	END TRY
	
	BEGIN CATCH
		SELECT @Success=0,
				@Msg=ISNULL(@Msg,'') +CHAR(13)+CHAR(10) 
					+ 'SP:' + ISNULL(ERROR_PROCEDURE(),object_name(@@Procid))+CHAR(13)+CHAR(10)
					+ 'Line:'+CAST(ISNULL(ERROR_LINE(),0) AS VARCHAR(10))+CHAR(13)+CHAR(10)
					+ 'Msg:'+ ISNULL(Error_Message(),'')
		GOTO Rtn
	END CATCH	
	
	
 



	Success:
		SELECT @Success=1,@msg=''
		GOTO Rtn

	Rtn:


	    IF LEN(@Msg)='' AND @Success = 0 
		    SELECT @Msg=''



END


GO