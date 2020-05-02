----------------------------------------------------------------------------------------------------
-- Scripting Parameters
----------------------------------------------------------------------------------------------------

-- local LuaDebug   = require 'LuaDebugging'
-- LuaDebugging  = true   --> Override the global LuaDebugging variable by uncommenting this line.
-- LuaStatistics = true   --> Override the global LuaStatistics variable by uncommenting this line.


----------------------------------------------------------------------------------------------------
-- Local Constants
----------------------------------------------------------------------------------------------------

local DirectoryPagination = '/truyen/all?page='


----------------------------------------------------------------------------------------------------
-- Event Functions
----------------------------------------------------------------------------------------------------

-- Get info and chapter list for current manga.
function GetInfo()
  local v, x = nil
  local u = MaybeFillHost(MODULE.RootURL, URL)
  
  --[[Debug]] LuaDebug.WriteLogWithHeader('GetInfo', 'URL ->  ' .. u)
  if not HTTP.GET(u) then return net_problem end
  
  x = TXQuery.Create(HTTP.Document)
  MANGAINFO.Title     = x.XPathString('//meta[@property="og:title"]/@content')
  MANGAINFO.CoverLink = x.XPathString('//meta[@property="og:image"]/@content')
  MANGAINFO.Status    = MangaInfoStatusIfPos(x.XPathString('//div[@class="__info"]/p[starts-with(.,"Tình trạng:")]'), 'Đang tiến hành', 'Ngưng')
  MANGAINFO.Authors   = SeparateRight(x.XPathString('//div[@class="__info"]/p[starts-with(.,"Tác giả:")]'), ':')
  MANGAINFO.Genres    = Trim(SeparateRight(x.XPathString('//div[@class="__info"]/p[starts-with(.,"Thể loại:")]'), ':'))
  MANGAINFO.Summary   = x.XPathString('//meta[@property="og:description"]/@content')
  
  x.XPathHREFAll('//div[@class="table-scroll"]/table/tbody/tr/td[1]/a', MANGAINFO.ChapterLinks, MANGAINFO.ChapterNames)
  InvertStrings(MANGAINFO.ChapterLinks, MANGAINFO.ChapterNames)
  
  --[[Debug]] LuaDebug.PrintMangaInfo()
  --[[Debug]] LuaDebug.WriteStatistics('Chapters', MANGAINFO.ChapterLinks.Count .. '  (' .. MANGAINFO.Title .. ')')
  
  return no_error
end


-- Get the page count of the manga list of the current website.
function GetDirectoryPageNumber()
  local u = MODULE.RootURL .. DirectoryPagination .. 1
  
  --[[Debug]] LuaDebug.WriteLogWithHeader('GetDirectoryPageNumber', 'URL ->  ' .. u)
  if not HTTP.GET(u) then return net_problem end
  
  PAGENUMBER = tonumber(TXQuery.Create(HTTP.Document).XPathString('(//*[starts-with(@class,"pagination")]//a)[last()-1]'))
  
  --[[Debug]] LuaDebug.WriteStatistics('DirectoryPages', PAGENUMBER)
  
  return no_error
end


-- Get LINKS and NAMES from the manga list of the current website.
function GetNameAndLink()
  local x = nil
  local u = MODULE.RootURL .. DirectoryPagination .. IncStr(URL)
  
  --[[Debug]] LuaDebug.WriteLogWithHeader('GetNameAndLink', 'URL ->  ' .. u)
  if not HTTP.GET(u) then return net_problem end
  
  x = TXQuery.Create(HTTP.Document)
  x.XPathHREFAll('//table[1]/tbody/tr/td[1]/a', LINKS, NAMES)
  
  --[[Debug]] LuaDebug.PrintMangaDirectoryEntries(IncStr(URL))
  
  return no_error
end


-- Get the page count for the current chapter.
function GetPageNumber()
  local s, x = nil
  local u = MaybeFillHost(MODULE.RootURL, URL)
  
  --[[Debug]] LuaDebug.WriteLogWithHeader('GetPageNumber', 'URL ->  ' .. u)
  if not HTTP.GET(u) then return net_problem end
  
  TXQuery.Create(HTTP.Document).XPathStringAll('//*[@class="manga-container"]/img/@src', TASK.PageLinks)
  
  --[[Debug]] LuaDebug.PrintChapterPageLinks()
  --[[Debug]] LuaDebug.WriteStatistics('ChapterPages', TASK.PageLinks.Count .. '  (' .. u .. ')')
  
  return no_error
end


----------------------------------------------------------------------------------------------------
-- Module Initialization
----------------------------------------------------------------------------------------------------

function Init()
  local m = NewWebsiteModule()
  m.ID                       = '4269c1fceff2471d84d32ccfbfe2d541'
  m.Name                     = 'AcademyVN'
  m.RootURL                  = 'https://hocvientruyentranh.net'
  m.Category                 = 'Vietnamese'
  m.OnGetInfo                = 'GetInfo'
  m.OnGetDirectoryPageNumber = 'GetDirectoryPageNumber'
  m.OnGetNameAndLink         = 'GetNameAndLink'
  m.OnGetPageNumber          = 'GetPageNumber'
end