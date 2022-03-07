
go

declare @json nvarchar(max)
select @json='{}'
select @json=(
    select *
    from (
        select fordno='No3',fdate=getdate(),fqty=1.0,frow=1,fremark=null
        union all
        select fordno='no2',fdate=getdate(),fqty=1.00,frow=2,fremark=''

        union all
        select fordno='no4',fdate=getdate(),fqty=1.00,frow=3,fremark=(select item=2 for json path,include_null_values)
    )a
    for json path,include_null_values,root('mst')
)
--转换成xml  就可以直接在 studio 里 复制超长json数据
--转换
--select [JSON_F52E2B61-18A1-11d1-B105-00805F49916B]=@json
--select convert(xml,@json)

select @json
--select @json=JSON_MODIFY(@json,'$.mst[0].fordno','No1')
--select JSON_QUERY(@json,'$.mst[0]')
--select JSON_VAlUE(@json,'$.mst[0].fordno')


select * from dbo.parseJSON(@json)

declare @tmp Hierarchy
insert into @tmp
    (element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType)
select element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType
from dbo.parseJSON(@json)

select @json=dbo.ToJSON(@tmp)
select @json
go



