
go

declare @json nvarchar(max)
select @json='{}'
select @json=(
    select *
    from (
        select fordno='No3',fdate=getdate(),fqty=1.0,frow=1
        union all
        select fordno='no2',fdate=getdate(),fqty=1.00,frow=2
    )a
    for json path,include_null_values,root('mst')
)
--转换成xml  就可以直接在 studio 里 复制超长json数据
--转换
--select [JSON_F52E2B61-18A1-11d1-B105-00805F49916B]=@json
--select convert(xml,@json)

select @json=JSON_MODIFY(@json,'$.mst[0].fordno','No1')
--select @json

select JSON_QUERY(@json,'$.mst[0]')
select JSON_VAlUE(@json,'$.mst[0].fordno')

go



