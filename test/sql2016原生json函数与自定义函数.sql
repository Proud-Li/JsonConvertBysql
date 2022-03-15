go

declare @json nvarchar(max)
select @json='{}'

--Table->JSON
select @json=
    (select 
        mst=(
            select 'No1' as ordno
            for json path,include_null_values
        )
        ,item=(
            select a.*
                ,1.0 as fdec
                ,2147483647 as maxint
                ,-2147483648 as minint
                ,4294967294 as fbigint
            from (
                select ordno='No1',date=getdate(),qty=-1.000000
                    ,row=1,sku='a',remark=null
                union all
                select ordno='no2',date=getdate(),qty=12345678912345.123456789123
                    ,row=2,sku='b',remark=''
                union all
                select ordno='no4',date=getdate(),qty=1.00
                    ,row=3,sku='c',remark=(select item=2 for json path,include_null_values)
            )a
            for json path,include_null_values
        )
    for json path
        ,include_null_values    --包含null值
        ,WITHOUT_ARRAY_WRAPPER  --删除方括号[] 即从数组变成obj
        --,root('top')          --添加根节点
    )

--转换成xml  就可以直接在 studio 里 复制超长json数据
--转换
select [JSON_F52E2B61-18A1-11d1-B105-00805F49916B]=@json
--select convert(xml,@json)

--官方方法
--select @json=JSON_MODIFY(@json,'$.mst[0].fordno','No1')
--select JSON_QUERY(@json,'$.mst[0]')
--select JSON_VAlUE(@json,'$.mst[0].fordno')


--自定义方法
--JSON->Hierarchy
select * from dbo.parseJSON(@json) a
where a.NAME='qty'

--Hierarchy->JSON
declare @tmp Hierarchy
insert into @tmp
    (element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType)
select element_id,sequenceNo,parent_ID,[Object_ID],[NAME],StringValue,ValueType
from dbo.parseJSON(@json)

select @json=dbo.ToJSON(@tmp)
select jsonxml=convert(xml,@json)



--行列转换
--JSON->Hierarchy->Table
exec convertJSON @JSON,'item'


--
		

go


