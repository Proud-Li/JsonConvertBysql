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

Note:

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

	 
	declare @tmp2 Hierarchy

	insert into @tmp1
		(element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType)
	select a.element_id,a.sequenceNo,a.parent_ID,a.[Object_ID],a.[NAME],a.StringValue,a.ValueType
	from dbo.parseJSON(@json) a

	 

	insert into @tmp2
		(element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType)
	select a.element_id,a.sequenceNo,a.parent_ID,a.[Object_ID],a.[NAME],a.StringValue,a.ValueType
	from @tmp1 a
	left join @tmp1 b on a.parent_ID=b.[Object_ID]
	left join @tmp1 c on b.parent_ID=c.[Object_ID]
	where c.[NAME]=@NAME


	select @sql="
		select a.parent_ID"
	select @sql=@sql+"  
			,max(case when a.[NAME]='"+a.[NAME]+"' then a.StringValue else '' end) as ["+a.[NAME]+"]"  
	from (select distinct [NAME] from @tmp2 a) a  

	set @sql = @sql +"
		from #tmp2 a   
		group by a.parent_ID 
		"
	--print(@sql)  
	select convert(xml,@sql)
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