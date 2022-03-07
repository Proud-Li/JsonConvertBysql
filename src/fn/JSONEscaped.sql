IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[JSONEscaped]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[JSONEscaped]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
******************************************************************************************
Purpose:   
Author:     
Date:       

Note:
this is a simple utility function that takes a SQL String 
with all its clobber and outputs it as a sting with all the JSON escape sequences in it.

Modified history
-----------------
Date			Modifier		Task			Remark
----------		---------		-----------		---------------------------------


desc
******************************************************************************************
*/
CREATE FUNCTION [JSONEscaped] ( 
  @Unescaped NVARCHAR(MAX) --a string with maybe characters that will break json
  )
RETURNS NVARCHAR(MAX)
AS 
BEGIN
  SELECT  @Unescaped = REPLACE(@Unescaped, FromString, ToString)
  FROM    (SELECT
            '\"' AS FromString, '"' AS ToString
           UNION ALL SELECT '\', '\\'
           UNION ALL SELECT '/', '\/'
           UNION ALL SELECT  CHAR(08),'\b'
           UNION ALL SELECT  CHAR(12),'\f'
           UNION ALL SELECT  CHAR(10),'\n'
           UNION ALL SELECT  CHAR(13),'\r'
           UNION ALL SELECT  CHAR(09),'\t'
          ) substitutions
RETURN @Unescaped
END