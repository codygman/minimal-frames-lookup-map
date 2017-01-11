{-# LANGUAGE DataKinds,
             OverloadedStrings,
             FlexibleContexts,
             TemplateHaskell
#-}

module Main where

import qualified Data.Map.Strict as M
import qualified Pipes.Prelude as P
import Pipes hiding (Proxy)
import Frames
import qualified Data.Judy as J

tableTypes "Row" "data/purchasing-card-data-2014-large.csv"

rows :: Producer Row IO ()
rows = readTable "data/purchasing-card-data-2014-large.csv"


--   hEmpty <- J.new :: IO (J.JudyL Int)
--   P.fold (\m r -> J.insert r ("text" :: T.Text) m) hEmpty id (P.each [0..iterations])


main :: IO ()
main = do
  -- generate a lookup map based on a producer
  -- lookupMap <- P.fold (\m r -> M.insert (rget jVReference r) (rget serviceArea r) m) M.empty id rows
  hEmpty <- J.new :: IO (J.JudyL Int)
  lookupMap <- P.fold (\m r -> J.insert (rget jVReference r) (rget serviceArea r) m) hEmpty id rows

  -- filter some rows based on said lookupMap
  print =<< P.length (rows >-> P.filter (\r -> rget jVReference r `M.member` lookupMap))

-- prof
-- 	Tue Jan 10 23:11 2017 Time and Allocation Profiling Report  (Final)

-- 	   minimal-frames-lookup-map +RTS -N -p -RTS

-- 	total time  =      103.53 secs   (103534 ticks @ 1000 us, 1 processor)
-- 	total alloc = 128,657,912,192 bytes  (excludes profiling overheads)

-- COST CENTRE                               MODULE                  SRC                                         %time %alloc

-- unpack.go                                 Data.Text.Internal.IO   Data/Text/Internal/IO.hs:(98,3)-(102,47)     14.1    2.4
-- >>=.\                                     Data.Text.Internal.Read Data/Text/Internal/Read.hs:(42,26)-(44,56)    7.1    1.7
-- _bind.go                                  Pipes.Internal          src/Pipes/Internal.hs:(99,5)-(103,29)         6.6    8.3
-- unpack.go.next                            Data.Text.Internal.IO   Data/Text/Internal/IO.hs:(100,5)-(101,44)     6.1    0.0
-- tokenizeRow                               Frames.CSV              src/Frames/CSV.hs:(92,1)-(98,72)              6.0   12.6
-- hGetLineLoop.go.findEOL                   Data.Text.Internal.IO   Data/Text/Internal/IO.hs:(51,7)-(56,29)       5.3    0.4
-- reassembleRFC4180QuotedParts.prefixQuoted Frames.CSV              src/Frames/CSV.hs:(115,9)-(117,81)            4.7   18.7
-- readRec                                   Frames.CSV              src/Frames/CSV.hs:(178,3)-(179,50)            4.1    4.3
-- reassembleRFC4180QuotedParts.f            Frames.CSV              src/Frames/CSV.hs:(105,9)-(113,62)            3.8   15.7
-- readTextDevice                            Data.Text.Internal.IO   Data/Text/Internal/IO.hs:133:39-64            3.5    0.2
-- reassembleRFC4180QuotedParts              Frames.CSV              src/Frames/CSV.hs:(103,1)-(129,54)            2.6    1.6
-- decimal                                   Data.Text.Read          Data/Text/Read.hs:(63,1)-(67,55)              2.3    4.7
-- parse                                     Frames.ColumnTypeable   src/Frames/ColumnTypeable.hs:42:3-56          2.3    2.9
-- main.\                                    Main                    src/Main.hs:22:32-83                          2.3    2.6
-- rows                                      Main                    src/Main.hs:17:1-59                           2.3    4.1
-- decimal.go                                Data.Text.Read          Data/Text/Read.hs:67:9-55                     1.9    1.4
-- liftIO                                    Pipes.Internal          src/Pipes/Internal.hs:165:5-55                1.8    2.0
-- parse'                                    Frames.ColumnTypeable   src/Frames/ColumnTypeable.hs:35:1-39          1.6    0.0
-- reassembleRFC4180QuotedParts.suffixQuoted Frames.CSV              src/Frames/CSV.hs:(118,9)-(120,84)            1.5    0.0
-- ==                                        Data.Text               Data/Text.hs:(324,5)-(326,30)                 1.3    0.0
-- main.\                                    Main                    src/Main.hs:25:48-86                          1.2    0.0
-- hGetLineLoop.go                           Data.Text.Internal.IO   Data/Text/Internal/IO.hs:(50,2)-(82,42)       1.1    2.2
-- perhaps.\                                 Data.Text.Internal.Read Data/Text/Internal/Read.hs:(51,27)-(53,44)    1.1    0.7
-- hGetLineWith                              Data.Text.Internal.IO   Data/Text/Internal/IO.hs:(44,1)-(46,79)       0.9    2.1
-- _bind.go.\                                Pipes.Internal          src/Pipes/Internal.hs:102:43-56               0.9    1.8
-- concat.ts'                                Data.Text               Data/Text.hs:899:5-34                         0.8    1.1
-- parse                                     Frames.ColumnTypeable   src/Frames/ColumnTypeable.hs:24:3-36          0.8    1.5


--                                                                                                                                                       individual      inherited
-- COST CENTRE                                           MODULE                          SRC                                         no.      entries  %time %alloc   %time %alloc

-- MAIN                                                  MAIN                            <built-in>                                   775          0    0.0    0.0   100.0  100.0
--  CAF                                                  GHC.IO.Encoding                 <entire-module>                              813          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.IO.Encoding.Iconv           <entire-module>                              812          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.IO.Handle.FD                <entire-module>                              811          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.IO.Handle.Text              <entire-module>                              810          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.Event.Thread                <entire-module>                              806          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.Conc.Signal                 <entire-module>                              803          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.Event.EPoll                 <entire-module>                              795          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.Event.Poll                  <entire-module>                              793          0    0.0    0.0     0.0    0.0
--  CAF                                                  GHC.IO.FD                       <entire-module>                              787          0    0.0    0.0     0.0    0.0
--  CAF:$fAlternativeProxy2                              Pipes.Internal                  <no location info>                           841          0    0.0    0.0     0.0    0.0
--   pure                                                Pipes.Internal                  src/Pipes/Internal.hs:80:5-20               1732          1    0.0    0.0     0.0    0.0
--  CAF:$fApplicativeIParser_$creturn                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:41:5-10           883          0    0.0    0.0     0.0    0.0
--   return                                              Data.Text.Internal.Read         Data/Text/Internal/Read.hs:41:5-21          1691          1    0.0    0.0     0.0    0.0
--  CAF:$fReadableInt1                                   Data.Readable                   <no location info>                          1242          0    0.0    0.0     0.0    0.0
--   fromText                                            Data.Readable                   src/Data/Readable.hs:66:5-66                1641          0    0.0    0.0     0.0    0.0
--    runP                                               Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1642          1    0.0    0.0     0.0    0.0
--    signa                                              Data.Text.Read                  Data/Text/Read.hs:(171,1)-(173,45)          1643          1    0.0    0.0     0.0    0.0
--     >>=                                               Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,5)-(44,56)   1644          1    0.0    0.0     0.0    0.0
--  CAF:$s$fRElemar:S_$s$fRElemar:S_$cp1RElem1           Main                            <no location info>                          1544          0    0.0    0.0     0.0    0.0
--  CAF:$s$fRElemar:S_$s$fRElemar:S_$cp1RElem2           Main                            <no location info>                          1545          0    0.0    0.0     0.0    0.0
--  CAF:$sreadTable4                                     Main                            <no location info>                          1529          0    0.0    0.0     0.0    0.0
--   readRec                                             Frames.CSV                      src/Frames/CSV.hs:(178,3)-(179,50)          1661          0    0.0    0.0     0.0    0.0
--    parse'                                             Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:35:1-39        1662          0    0.0    0.0     0.0    0.0
--     parse                                             Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:42:3-56        1663          1    0.0    0.0     0.0    0.0
--      fromText                                         Data.Readable                   src/Data/Readable.hs:72:5-58                1665          1    0.0    0.0     0.0    0.0
--  CAF:defaultParser                                    Frames.CSV                      src/Frames/CSV.hs:81:1-13                   1399          0    0.0    0.0     0.0    0.0
--   defaultParser                                       Frames.CSV                      src/Frames/CSV.hs:81:1-70                   1570          1    0.0    0.0     0.0    0.0
--  CAF:defaultSep                                       Frames.CSV                      src/Frames/CSV.hs:85:1-10                   1396          0    0.0    0.0     0.0    0.0
--   defaultSep                                          Frames.CSV                      src/Frames/CSV.hs:85:1-23                   1608          1    0.0    0.0     0.0    0.0
--    shiftL                                             Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1609          1    0.0    0.0     0.0    0.0
--    shiftR                                             Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1610          1    0.0    0.0     0.0    0.0
--  CAF:defaultSep2                                      Frames.CSV                      <no location info>                          1395          0    0.0    0.0     0.0    0.0
--   defaultSep                                          Frames.CSV                      src/Frames/CSV.hs:85:1-23                   1611          0    0.0    0.0     0.0    0.0
--  CAF:double                                           Data.Text.Read                  Data/Text/Read.hs:160:1-6                    882          0    0.0    0.0     0.0    0.0
--   double                                              Data.Text.Read                  Data/Text/Read.hs:(160,1)-(162,61)          1667          1    0.0    0.0     0.0    0.0
--    >>=                                                Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,5)-(44,56)   1669          1    0.0    0.0     0.0    0.0
--    runP                                               Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1668          1    0.0    0.0     0.0    0.0
--  CAF:empty                                            Data.Text.Array                 Data/Text/Array.hs:173:1-5                  1126          0    0.0    0.0     0.0    0.0
--   empty                                               Data.Text.Array                 Data/Text/Array.hs:173:1-38                 1615          1    0.0    0.0     0.0    0.0
--    shiftL                                             Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1616          1    0.0    0.0     0.0    0.0
--    shiftR                                             Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1617          1    0.0    0.0     0.0    0.0
--  CAF:empty                                            Data.Text.Internal              Data/Text/Internal.hs:82:1-5                 974          0    0.0    0.0     0.0    0.0
--  CAF:getLine2                                         Data.Text.IO                    <no location info>                           991          0    0.0    0.0     0.0    0.0
--   hGetLine                                            Data.Text.IO                    Data/Text/IO.hs:169:1-32                    1571          1    0.0    0.0     0.0    0.0
--  CAF:lvl52_r5qdE                                      Data.Text                       <no location info>                          1187          0    0.0    0.0     0.0    0.0
--   concat                                              Data.Text                       Data/Text.hs:(894,1)-(906,36)               1719          0    0.0    0.0     0.0    0.0
--    concat.len                                         Data.Text                       Data/Text.hs:900:5-48                       1720          0    0.0    0.0     0.0    0.0
--     sumP                                              Data.Text                       Data/Text.hs:(1724,1)-(1729,27)             1721          1    0.0    0.0     0.0    0.0
--  CAF:m2_rdq0n                                         Data.Text.Read                  <no location info>                           880          0    0.0    0.0     0.0    0.0
--   double                                              Data.Text.Read                  Data/Text/Read.hs:(160,1)-(162,61)          1679          0    0.0    0.0     0.0    0.0
--    char                                               Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1680          1    0.0    0.0     0.0    0.0
--  CAF:m3_rdq0o                                         Data.Text.Read                  <no location info>                           881          0    0.0    0.0     0.0    0.0
--   double                                              Data.Text.Read                  Data/Text/Read.hs:(160,1)-(162,61)          1674          0    0.0    0.0     0.0    0.0
--    perhaps                                            Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1675          1    0.0    0.0     0.0    0.0
--  CAF:main1                                            Main                            <no location info>                          1548          0    0.0    0.0     0.0    0.0
--   main                                                Main                            src/Main.hs:(20,1)-(25,88)                  1550          1    0.0    0.0     0.0    0.0
--  CAF:rows                                             Main                            src/Main.hs:17:1-4                          1537          0    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1552          1    0.0    0.0     0.0    0.0
--  CAF:rows3                                            Main                            <no location info>                          1534          0    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1731          0    0.0    0.0     0.0    0.0
--  CAF:rows8                                            Main                            <no location info>                          1527          0    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1568          0    0.0    0.0     0.0    0.0
--  CAF:rows_go1                                         Main                            <no location info>                          1536          0    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1553          0    0.0    0.0     0.0    0.0
--    >>=                                                Pipes.Internal                  src/Pipes/Internal.hs:91:5-18               1554          1    0.0    0.0     0.0    0.0
--     _bind                                             Pipes.Internal                  src/Pipes/Internal.hs:(98,1)-(103,29)       1555          1    0.0    0.0     0.0    0.0
--      _bind.go                                         Pipes.Internal                  src/Pipes/Internal.hs:(99,5)-(103,29)       1556          1    0.0    0.0     0.0    0.0
--  CAF:rows_p1                                          Main                            <no location info>                          1535          0    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1557          0    0.0    0.0     0.0    0.0
--    >>=                                                Pipes.Internal                  src/Pipes/Internal.hs:91:5-18               1558          1    0.0    0.0     0.0    0.0
--     _bind                                             Pipes.Internal                  src/Pipes/Internal.hs:(98,1)-(103,29)       1559          1    0.0    0.0     0.0    0.0
--      _bind.go                                         Pipes.Internal                  src/Pipes/Internal.hs:(99,5)-(103,29)       1560          1    0.0    0.0     0.0    0.0
--    liftIO                                             Pipes.Internal                  src/Pipes/Internal.hs:165:5-55              1561          1    0.0    0.0     0.0    0.0
--  CAF:rows_quoting                                     Main                            <no location info>                          1533          0    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1595          0    0.0    0.0     0.0    0.0
--    liftIO                                             Pipes.Internal                  src/Pipes/Internal.hs:165:5-55              1596          0    0.0    0.0     0.0    0.0
--     readRow                                           Frames.CSV                      src/Frames/CSV.hs:183:1-35                  1597          0    0.0    0.0     0.0    0.0
--      tokenizeRow                                      Frames.CSV                      src/Frames/CSV.hs:(92,1)-(98,72)            1598          0    0.0    0.0     0.0    0.0
--       tokenizeRow.quoting                             Frames.CSV                      src/Frames/CSV.hs:95:9-37                   1599          1    0.0    0.0     0.0    0.0
--        quotingMode                                    Frames.CSV                      src/Frames/CSV.hs:62:38-48                  1600          1    0.0    0.0     0.0    0.0
--  CAF:rows_sep                                         Main                            <no location info>                          1532          0    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1602          0    0.0    0.0     0.0    0.0
--    liftIO                                             Pipes.Internal                  src/Pipes/Internal.hs:165:5-55              1603          0    0.0    0.0     0.0    0.0
--     readRow                                           Frames.CSV                      src/Frames/CSV.hs:183:1-35                  1604          0    0.0    0.0     0.0    0.0
--      tokenizeRow                                      Frames.CSV                      src/Frames/CSV.hs:(92,1)-(98,72)            1605          0    0.0    0.0     0.0    0.0
--       tokenizeRow.sep                                 Frames.CSV                      src/Frames/CSV.hs:94:9-37                   1606          1    0.0    0.0     0.0    0.0
--        columnSeparator                                Frames.CSV                      src/Frames/CSV.hs:61:38-52                  1607          1    0.0    0.0     0.0    0.0
--  CAF:signed1                                          Data.Text.Read                  <no location info>                           874          0    0.0    0.0     0.0    0.0
--   signa                                               Data.Text.Read                  Data/Text/Read.hs:(171,1)-(173,45)          1649          0    0.0    0.0     0.0    0.0
--    perhaps                                            Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1650          1    0.0    0.0     0.0    0.0
--  CAF:signed3                                          Data.Text.Read                  <no location info>                           873          0    0.0    0.0     0.0    0.0
--   signa                                               Data.Text.Read                  Data/Text/Read.hs:(171,1)-(173,45)          1654          0    0.0    0.0     0.0    0.0
--    char                                               Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1655          1    0.0    0.0     0.0    0.0
--  main                                                 Main                            src/Main.hs:(20,1)-(25,88)                  1551          0    0.7    0.0   100.0  100.0
--   >>=                                                 Pipes.Internal                  src/Pipes/Internal.hs:91:5-18               1733   11961723    0.1    0.3    49.0   49.6
--    _bind                                              Pipes.Internal                  src/Pipes/Internal.hs:(98,1)-(103,29)       1734   11961723    0.4    0.5    48.9   49.3
--     _bind.go                                          Pipes.Internal                  src/Pipes/Internal.hs:(99,5)-(103,29)       1735   53946254    3.4    4.8    48.2   47.8
--      _bind.go.\                                       Pipes.Internal                  src/Pipes/Internal.hs:100:46-56             1761    6004561    0.1    0.1     0.1    0.1
--       rows                                            Main                            src/Main.hs:17:1-59                         1762          0    0.0    0.0     0.0    0.0
--      _bind.go.\                                       Pipes.Internal                  src/Pipes/Internal.hs:101:46-56             1741    5980864    0.1    0.1     0.1    0.1
--       rows                                            Main                            src/Main.hs:17:1-59                         1743          0    0.0    0.0     0.0    0.0
--      main.\                                           Main                            src/Main.hs:25:48-86                        1834    5980861    1.2    0.0     1.7    0.0
--       rlens                                           Data.Vinyl.Lens                 Data/Vinyl/Lens.hs:78:3-50                  1835   23923444    0.3    0.0     0.4    0.0
--        rlens                                          Data.Vinyl.Lens                 Data/Vinyl/Lens.hs:74:3-42                  1840    5980861    0.1    0.0     0.1    0.0
--         fmap                                          Data.Vinyl.Functor              Data/Vinyl/Functor.hs:47:16-22              1842    5980861    0.0    0.0     0.0    0.0
--         getIdentity                                   Data.Vinyl.Functor              Data/Vinyl/Functor.hs:46:16-26              1841    5980861    0.0    0.0     0.0    0.0
--      return                                           Pipes.Internal                  src/Pipes/Internal.hs:90:5-17               1860          1    0.0    0.0     0.0    0.0
--      _bind.go.\                                       Pipes.Internal                  src/Pipes/Internal.hs:102:43-56             1747          0    0.1    0.0     0.1    0.0
--      liftIO                                           Pipes.Internal                  src/Pipes/Internal.hs:165:5-55              1744          0    0.9    1.0    41.6   40.7
--       liftIO.\                                        Pipes.Internal                  src/Pipes/Internal.hs:165:39-53             1745   12009123    0.0    0.0     0.0    0.0
--       readRow                                         Frames.CSV                      src/Frames/CSV.hs:183:1-35                  1763    6004561    0.1    0.0    23.7   34.4
--        readRec                                        Frames.CSV                      src/Frames/CSV.hs:(178,3)-(179,50)          1788   42031927    2.1    2.2    12.9    9.2
--         parse'                                        Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:35:1-39        1789   42031927    0.8    0.0    10.8    7.0
--          discardConfidence                            Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:(29,1)-(30,36) 1836   41866027    0.2    0.0     0.2    0.0
--          parse                                        Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:24:3-36        1790   36027366    0.4    0.7     1.8    2.1
--           fromText                                    Data.Readable                   src/Data/Readable.hs:63:5-21                1791   30022805    0.0    0.0     0.0    0.0
--           fromText                                    Data.Readable                   src/Data/Readable.hs:66:5-66                1792    6004561    0.1    0.0     1.4    1.4
--            checkComplete                              Data.Readable                   src/Data/Readable.hs:(52,1)-(54,23)         1804    6004561    0.0    0.0     0.0    0.0
--            signa                                      Data.Text.Read                  Data/Text/Read.hs:(171,1)-(173,45)          1793          0    0.1    0.0     1.3    1.4
--             >>=                                       Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,5)-(44,56)   1794          0    0.0    0.0     0.9    1.2
--              >>=.\                                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,26)-(44,56)  1795    6004561    0.2    0.0     0.9    1.2
--               runP                                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1796   12009122    0.0    0.0     0.0    0.0
--               decimal                                 Data.Text.Read                  Data/Text/Read.hs:(63,1)-(67,55)            1803    6004561    0.4    0.9     0.6    1.2
--                decimal.go                             Data.Text.Read                  Data/Text/Read.hs:67:9-55                   1838   22701288    0.2    0.3     0.2    0.3
--                 digitToInt                            Data.Text.Internal.Read         Data/Text/Internal/Read.hs:62:1-30          1839   22701288    0.0    0.0     0.0    0.0
--                shiftR                                 Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1837    5980861    0.0    0.0     0.0    0.0
--             char                                      Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1800          0    0.0    0.0     0.1    0.0
--              char.\                                   Data.Text.Read                  Data/Text/Read.hs:(176,20)-(178,73)         1801    6004561    0.1    0.0     0.1    0.0
--               signa.\                                 Data.Text.Read                  Data/Text/Read.hs:172:37-56                 1802    6004561    0.0    0.0     0.0    0.0
--             perhaps                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1797          0    0.0    0.0     0.2    0.2
--              perhaps.\                                Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,27)-(53,44)  1798    6004561    0.1    0.2     0.1    0.2
--               runP                                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1799    6004561    0.0    0.0     0.0    0.0
--          parse                                        Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:42:3-56        1805          0    1.1    1.4     8.1    4.9
--           shiftR                                      Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1816   12009122    0.0    0.0     0.0    0.0
--           shiftL                                      Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1817    6004561    0.0    0.0     0.0    0.0
--           fromText                                    Data.Readable                   src/Data/Readable.hs:72:5-58                1806          0    0.4    0.1     7.0    3.4
--            checkComplete                              Data.Readable                   src/Data/Readable.hs:(52,1)-(54,23)         1833    5980861    0.1    0.1     0.1    0.1
--            double                                     Data.Text.Read                  Data/Text/Read.hs:(160,1)-(162,61)          1807          0    0.1    0.0     6.4    3.2
--             >>=                                       Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,5)-(44,56)   1808   38878227    0.3    0.0     6.1    3.0
--              >>=.\                                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,26)-(44,56)  1809   44882788    3.3    0.9     5.8    3.0
--               runP                                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1810   82255265    0.0    0.0     0.0    0.0
--               char                                    Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1824   11961722    0.3    0.0     0.3    0.0
--                char.\                                 Data.Text.Read                  Data/Text/Read.hs:(176,20)-(178,73)         1825   11961722    0.0    0.0     0.0    0.0
--               perhaps                                 Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1821   11961722    0.2    0.0     0.4    0.0
--                perhaps.\                              Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,27)-(53,44)  1822   11961722    0.3    0.0     0.3    0.0
--                 runP                                  Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1823   11961722    0.0    0.0     0.0    0.0
--               decimal                                 Data.Text.Read                  Data/Text/Read.hs:(63,1)-(67,55)            1818   10479672    0.7    1.4     1.5    1.8
--                decimal.go                             Data.Text.Read                  Data/Text/Read.hs:67:9-55                   1829   19656261    0.7    0.4     0.7    0.4
--                 digitToInt                            Data.Text.Internal.Read         Data/Text/Internal/Read.hs:62:1-30          1830   19656261    0.0    0.0     0.0    0.0
--                shiftR                                 Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1828   10455972    0.0    0.0     0.0    0.0
--               pure                                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:36:5-34          1826   10455972    0.1    0.3     0.1    0.3
--                pure.\                                 Data.Text.Internal.Read         Data/Text/Internal/Read.hs:36:24-34         1827   10455972    0.0    0.0     0.0    0.0
--               double.\                                Data.Text.Read                  Data/Text/Read.hs:(161,20)-(162,61)         1832    4475111    0.2    0.0     0.2    0.0
--               shiftR                                  Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1831    4475111    0.0    0.0     0.0    0.0
--             char                                      Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1814          0    0.0    0.0     0.0    0.0
--              char.\                                   Data.Text.Read                  Data/Text/Read.hs:(176,20)-(178,73)         1815    6004561    0.0    0.0     0.0    0.0
--             perhaps                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1811          0    0.0    0.0     0.1    0.2
--              perhaps.\                                Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,27)-(53,44)  1812    6004561    0.1    0.2     0.1    0.2
--               runP                                    Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1813    6004561    0.0    0.0     0.0    0.0
--         readRec                                       Frames.CSV                      src/Frames/CSV.hs:175:3-17                  1819    6004561    0.0    0.0     0.0    0.0
--        tokenizeRow                                    Frames.CSV                      src/Frames/CSV.hs:(92,1)-(98,72)            1764    6004561    3.0    6.3    10.7   25.2
--         shiftR                                        Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1769    6004561    0.0    0.0     0.0    0.0
--         tokenizeRow.handleQuoting                     Frames.CSV                      src/Frames/CSV.hs:(96,9)-(98,72)            1765    6004561    0.1    0.1     7.7   18.9
--          reassembleRFC4180QuotedParts                 Frames.CSV                      src/Frames/CSV.hs:(103,1)-(129,54)          1766    6004561    1.2    0.8     7.6   18.8
--           reassembleRFC4180QuotedParts.f              Frames.CSV                      src/Frames/CSV.hs:(105,9)-(113,62)          1770   42055627    1.9    7.8     5.5   16.7
--            reassembleRFC4180QuotedParts.suffixQuoted  Frames.CSV                      src/Frames/CSV.hs:(118,9)-(120,84)          1784   42079327    0.8    0.0     1.4    0.0
--             ==                                        Data.Text                       Data/Text.hs:(324,5)-(326,30)               1785   42079327    0.7    0.0     0.7    0.0
--              aBA                                      Data.Text.Array                 Data/Text/Array.hs:84:7-9                   1786   84158654    0.0    0.0     0.0    0.0
--            reassembleRFC4180QuotedParts.prefixQuoted  Frames.CSV                      src/Frames/CSV.hs:(115,9)-(117,81)          1771   42055627    2.2    8.9     2.2    8.9
--             shiftR                                    Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1783   42103027    0.0    0.0     0.0    0.0
--           reassembleRFC4180QuotedParts.finish         Frames.CSV                      src/Frames/CSV.hs:(128,9)-(129,54)          1787    6004561    0.0    0.0     0.0    0.0
--           reassembleRFC4180QuotedParts.quoteText      Frames.CSV                      src/Frames/CSV.hs:122:9-41                  1773    6004561    0.1    0.0     0.7    0.7
--            singleton_                                 Data.Text.Show                  Data/Text/Show.hs:(81,1)-(88,18)            1774    6004561    0.3    0.5     0.6    0.7
--             run                                       Data.Text.Array                 Data/Text/Array.hs:178:1-34                 1776    6004561    0.1    0.1     0.3    0.3
--              singleton_.x                             Data.Text.Show                  Data/Text/Show.hs:(83,9)-(85,25)            1777          0    0.2    0.2     0.2    0.2
--               shiftL                                  Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1778    6004561    0.0    0.0     0.0    0.0
--               shiftR                                  Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1781    6004561    0.0    0.0     0.0    0.0
--             singleton_.d                              Data.Text.Show                  Data/Text/Show.hs:88:9-18                   1780    6004561    0.0    0.0     0.0    0.0
--             singleton_.len                            Data.Text.Show                  Data/Text/Show.hs:(86,9)-(87,31)            1779    6004561    0.0    0.0     0.0    0.0
--             singleton_.x                              Data.Text.Show                  Data/Text/Show.hs:(83,9)-(85,25)            1775    6004561    0.0    0.0     0.0    0.0
--           reassembleRFC4180QuotedParts.prefixQuoted   Frames.CSV                      src/Frames/CSV.hs:(115,9)-(117,81)          1772          0    0.1    0.4     0.1    0.4
--            shiftR                                     Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1782    6004561    0.0    0.0     0.0    0.0
--       hGetLine                                        Data.Text.IO                    Data/Text/IO.hs:169:1-32                    1749          0    0.0    0.0    17.0    5.3
--        hGetLineWith                                   Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(44,1)-(46,79)     1750    6004561    0.5    1.0    16.9    5.3
--         hGetLineWith.go                               Data.Text.Internal.IO           Data/Text/Internal/IO.hs:46:5-79            1751    6004561    0.3    0.3    16.4    4.3
--          concat                                       Data.Text                       Data/Text.hs:(894,1)-(906,36)               1767    6004561    0.3    0.0     0.9    0.7
--           concat.ts'                                  Data.Text                       Data/Text.hs:899:5-34                       1768    6004561    0.4    0.5     0.4    0.5
--           concat.go                                   Data.Text                       Data/Text.hs:(902,5)-(906,36)               1847     269254    0.0    0.0     0.0    0.0
--           concat.len                                  Data.Text                       Data/Text.hs:900:5-48                       1851     269254    0.0    0.0     0.1    0.1
--            sumP                                       Data.Text                       Data/Text.hs:(1724,1)-(1729,27)             1852          0    0.0    0.0     0.0    0.0
--             sumP.go                                   Data.Text                       Data/Text.hs:(1725,9)-(1729,27)             1853     807762    0.0    0.0     0.0    0.0
--              sumP.go.ax                               Data.Text                       Data/Text.hs:1728:17-26                     1854     538508    0.0    0.0     0.0    0.0
--           run                                         Data.Text.Array                 Data/Text/Array.hs:178:1-34                 1848     269254    0.0    0.0     0.1    0.1
--            concat.go                                  Data.Text                       Data/Text.hs:(902,5)-(906,36)               1849          0    0.0    0.1     0.1    0.1
--             concat.go.step                            Data.Text                       Data/Text.hs:(904,11)-(905,61)              1856     538508    0.1    0.0     0.1    0.0
--              aBA                                      Data.Text.Array                 Data/Text/Array.hs:84:7-9                   1858     538508    0.0    0.0     0.0    0.0
--              concat.go.step.(...)                     Data.Text                       Data/Text.hs:905:17-26                      1857     538508    0.0    0.0     0.0    0.0
--              maBA                                     Data.Text.Array                 Data/Text/Array.hs:92:7-10                  1859     538508    0.0    0.0     0.0    0.0
--             shiftL                                    Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1850     269254    0.0    0.0     0.0    0.0
--             shiftR                                    Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1855     269254    0.0    0.0     0.0    0.0
--          hGetLineLoop                                 Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(49,1)-(82,42)     1752    6004561    0.2    0.4    15.3    3.2
--           hGetLineLoop.go                             Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(50,2)-(82,42)     1753    6279634    0.5    1.1    15.1    2.8
--            hGetLineLoop.go.findEOL                    Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(51,7)-(56,29)     1754  557024209    2.6    0.2     2.6    0.2
--            unpack                                     Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(93,1)-(102,47)    1755    6279634    0.1    0.2    10.2    1.4
--             unpack.go                                 Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(98,3)-(102,47)    1756    6273815    7.0    1.2    10.1    1.2
--              unpack.go.next                           Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(100,5)-(101,44)   1759  557018390    3.0    0.0     3.1    0.0
--               unpack.go.ix                            Data.Text.Internal.IO           Data/Text/Internal/IO.hs:102:5-47           1760  550744575    0.0    0.0     0.0    0.0
--              shiftL                                   Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1757    6273815    0.0    0.0     0.0    0.0
--              shiftR                                   Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1758    6273815    0.0    0.0     0.0    0.0
--            hGetLineLoop.go.buf1                       Data.Text.Internal.IO           Data/Text/Internal/IO.hs:66:11-37           1845     275073    0.0    0.0     0.0    0.0
--            maybeFillReadBuffer                        Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(86,1)-(90,20)     1843     275073    0.0    0.0     1.7    0.1
--             getSomeCharacters                         Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(130,1)-(151,52)   1844     275073    0.0    0.0     1.7    0.1
--              readTextDevice                           Data.Text.Internal.IO           Data/Text/Internal/IO.hs:133:39-64          1846     275073    1.7    0.1     1.7    0.1
--      rows                                             Main                            src/Main.hs:17:1-59                         1742          0    1.1    2.1     1.2    2.2
--       _bind.go.\                                      Pipes.Internal                  src/Pipes/Internal.hs:101:46-56             1820   11985422    0.1    0.1     0.1    0.1
--     _bind.go.\                                        Pipes.Internal                  src/Pipes/Internal.hs:102:43-56             1746   18013684    0.3    0.9     0.3    0.9
--      rows                                             Main                            src/Main.hs:17:1-59                         1748          0    0.0    0.0     0.0    0.0
--   main.\                                              Main                            src/Main.hs:22:32-83                        1701    5980862    2.3    2.6     2.8    2.6
--    rlens                                              Data.Vinyl.Lens                 Data/Vinyl/Lens.hs:78:3-50                  1702   23923448    0.3    0.0     0.5    0.0
--     rlens                                             Data.Vinyl.Lens                 Data/Vinyl/Lens.hs:74:3-42                  1707    5980862    0.1    0.0     0.1    0.0
--      fmap                                             Data.Vinyl.Functor              Data/Vinyl/Functor.hs:47:16-22              1709    5980862    0.0    0.0     0.0    0.0
--      getIdentity                                      Data.Vinyl.Functor              Data/Vinyl/Functor.hs:46:16-26              1708    5980862    0.0    0.0     0.0    0.0
--    rlens                                              Data.Vinyl.Lens                 Data/Vinyl/Lens.hs:74:3-42                  1710    5980862    0.1    0.0     0.1    0.0
--     fmap                                              Data.Vinyl.Functor              Data/Vinyl/Functor.hs:47:16-22              1712    5980862    0.0    0.0     0.0    0.0
--     getIdentity                                       Data.Vinyl.Functor              Data/Vinyl/Functor.hs:46:16-26              1711    5980862    0.0    0.0     0.0    0.0
--   main.\                                              Main                            src/Main.hs:25:48-86                        1736          1    0.0    0.0     0.0    0.0
--    rlens                                              Data.Vinyl.Lens                 Data/Vinyl/Lens.hs:78:3-50                  1737          4    0.0    0.0     0.0    0.0
--     rlens                                             Data.Vinyl.Lens                 Data/Vinyl/Lens.hs:74:3-42                  1738          1    0.0    0.0     0.0    0.0
--      fmap                                             Data.Vinyl.Functor              Data/Vinyl/Functor.hs:47:16-22              1740          1    0.0    0.0     0.0    0.0
--      getIdentity                                      Data.Vinyl.Functor              Data/Vinyl/Functor.hs:46:16-26              1739          1    0.0    0.0     0.0    0.0
--   rows                                                Main                            src/Main.hs:17:1-59                         1562          0    1.1    2.1    47.5   47.8
--    >>=                                                Pipes.Internal                  src/Pipes/Internal.hs:91:5-18               1563    5980869    0.0    0.1    46.4   45.8
--     _bind                                             Pipes.Internal                  src/Pipes/Internal.hs:(98,1)-(103,29)       1564    5980869    0.1    0.3    46.4   45.6
--      _bind.go                                         Pipes.Internal                  src/Pipes/Internal.hs:(99,5)-(103,29)       1565   41984548    3.1    3.5    46.2   45.3
--       _bind.go.\                                      Pipes.Internal                  src/Pipes/Internal.hs:102:43-56             1590   18013690    0.5    0.9     0.5    0.9
--       _bind.go.\                                      Pipes.Internal                  src/Pipes/Internal.hs:101:46-56             1713   11985424    0.2    0.1     0.2    0.1
--       _bind.go.\                                      Pipes.Internal                  src/Pipes/Internal.hs:100:46-56             1591    6004563    0.1    0.1     0.1    0.1
--       liftIO                                          Pipes.Internal                  src/Pipes/Internal.hs:165:5-55              1567          4    0.9    1.0    42.3   40.7
--        liftIO.\                                       Pipes.Internal                  src/Pipes/Internal.hs:165:39-53             1588   12009129    0.0    0.0     0.0    0.0
--        readRow                                        Frames.CSV                      src/Frames/CSV.hs:183:1-35                  1592    6004563    0.1    0.0    24.3   34.4
--         readRec                                       Frames.CSV                      src/Frames/CSV.hs:(178,3)-(179,50)          1636   42031941    2.0    2.2    13.2    9.2
--          parse'                                       Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:35:1-39        1637   42031941    0.8    0.0    11.2    7.0
--           discardConfidence                           Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:(29,1)-(30,36) 1703   41866041    0.2    0.0     0.2    0.0
--           parse                                       Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:24:3-36        1638   36027378    0.4    0.7     1.9    2.1
--            fromText                                   Data.Readable                   src/Data/Readable.hs:63:5-21                1639   30022815    0.0    0.0     0.0    0.0
--            fromText                                   Data.Readable                   src/Data/Readable.hs:66:5-66                1640    6004563    0.1    0.0     1.5    1.4
--             checkComplete                             Data.Readable                   src/Data/Readable.hs:(52,1)-(54,23)         1660    6004563    0.0    0.0     0.0    0.0
--             signa                                     Data.Text.Read                  Data/Text/Read.hs:(171,1)-(173,45)          1645          0    0.1    0.0     1.3    1.4
--              >>=                                      Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,5)-(44,56)   1646          0    0.1    0.0     0.9    1.2
--               >>=.\                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,26)-(44,56)  1647    6004563    0.2    0.0     0.9    1.2
--                runP                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1648   12009126    0.0    0.0     0.0    0.0
--                decimal                                Data.Text.Read                  Data/Text/Read.hs:(63,1)-(67,55)            1659    6004563    0.5    0.9     0.6    1.2
--                 decimal.go                            Data.Text.Read                  Data/Text/Read.hs:67:9-55                   1705   22701292    0.2    0.3     0.2    0.3
--                  digitToInt                           Data.Text.Internal.Read         Data/Text/Internal/Read.hs:62:1-30          1706   22701292    0.0    0.0     0.0    0.0
--                 shiftR                                Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1704    5980863    0.0    0.0     0.0    0.0
--              char                                     Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1656          0    0.0    0.0     0.1    0.0
--               char.\                                  Data.Text.Read                  Data/Text/Read.hs:(176,20)-(178,73)         1657    6004563    0.1    0.0     0.1    0.0
--                signa.\                                Data.Text.Read                  Data/Text/Read.hs:172:37-56                 1658    6004563    0.0    0.0     0.0    0.0
--              perhaps                                  Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1651          0    0.0    0.0     0.2    0.2
--               perhaps.\                               Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,27)-(53,44)  1652    6004563    0.1    0.2     0.1    0.2
--                runP                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1653    6004563    0.0    0.0     0.0    0.0
--           parse                                       Frames.ColumnTypeable           src/Frames/ColumnTypeable.hs:42:3-56        1664          0    1.2    1.4     8.3    4.9
--            shiftR                                     Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1683   12009126    0.0    0.0     0.0    0.0
--            shiftL                                     Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1684    6004563    0.0    0.0     0.0    0.0
--            fromText                                   Data.Readable                   src/Data/Readable.hs:72:5-58                1666          0    0.4    0.1     7.1    3.4
--             checkComplete                             Data.Readable                   src/Data/Readable.hs:(52,1)-(54,23)         1699    5980863    0.2    0.1     0.2    0.1
--             double                                    Data.Text.Read                  Data/Text/Read.hs:(160,1)-(162,61)          1670          0    0.2    0.0     6.6    3.2
--              >>=                                      Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,5)-(44,56)   1671   38878241    0.4    0.0     6.2    3.0
--               >>=.\                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(42,26)-(44,56)  1672   44882804    3.3    0.9     5.8    3.0
--                runP                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1673   82255295    0.0    0.0     0.0    0.0
--                char                                   Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1689   11961726    0.2    0.0     0.2    0.0
--                 char.\                                Data.Text.Read                  Data/Text/Read.hs:(176,20)-(178,73)         1690   11961726    0.0    0.0     0.0    0.0
--                perhaps                                Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1686   11961726    0.2    0.0     0.5    0.0
--                 perhaps.\                             Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,27)-(53,44)  1687   11961726    0.3    0.0     0.3    0.0
--                  runP                                 Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1688   11961726    0.0    0.0     0.0    0.0
--                decimal                                Data.Text.Read                  Data/Text/Read.hs:(63,1)-(67,55)            1685   10479676    0.7    1.4     1.5    1.8
--                 decimal.go                            Data.Text.Read                  Data/Text/Read.hs:67:9-55                   1695   19656271    0.8    0.4     0.8    0.4
--                  digitToInt                           Data.Text.Internal.Read         Data/Text/Internal/Read.hs:62:1-30          1696   19656271    0.0    0.0     0.0    0.0
--                 shiftR                                Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1694   10455976    0.0    0.0     0.0    0.0
--                pure                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:36:5-34          1692   10455976    0.1    0.3     0.1    0.3
--                 pure.\                                Data.Text.Internal.Read         Data/Text/Internal/Read.hs:36:24-34         1693   10455976    0.0    0.0     0.0    0.0
--                double.\                               Data.Text.Read                  Data/Text/Read.hs:(161,20)-(162,61)         1698    4475113    0.2    0.0     0.2    0.0
--                shiftR                                 Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1697    4475113    0.0    0.0     0.0    0.0
--              char                                     Data.Text.Read                  Data/Text/Read.hs:(176,1)-(178,73)          1681          0    0.0    0.0     0.1    0.0
--               char.\                                  Data.Text.Read                  Data/Text/Read.hs:(176,20)-(178,73)         1682    6004563    0.0    0.0     0.0    0.0
--              perhaps                                  Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,1)-(53,44)   1676          0    0.0    0.0     0.2    0.2
--               perhaps.\                               Data.Text.Internal.Read         Data/Text/Internal/Read.hs:(51,27)-(53,44)  1677    6004563    0.1    0.2     0.1    0.2
--                runP                                   Data.Text.Internal.Read         Data/Text/Internal/Read.hs:29:7-10          1678    6004563    0.0    0.0     0.0    0.0
--          readRec                                      Frames.CSV                      src/Frames/CSV.hs:175:3-17                  1700    6004563    0.0    0.0     0.0    0.0
--         tokenizeRow                                   Frames.CSV                      src/Frames/CSV.hs:(92,1)-(98,72)            1593    6004563    3.0    6.3    10.9   25.2
--          shiftR                                       Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1614    6004563    0.0    0.0     0.0    0.0
--          tokenizeRow.handleQuoting                    Frames.CSV                      src/Frames/CSV.hs:(96,9)-(98,72)            1594    6004563    0.1    0.1     7.9   18.9
--           reassembleRFC4180QuotedParts                Frames.CSV                      src/Frames/CSV.hs:(103,1)-(129,54)          1601    6004563    1.3    0.8     7.8   18.8
--            reassembleRFC4180QuotedParts.f             Frames.CSV                      src/Frames/CSV.hs:(105,9)-(113,62)          1618   42055641    1.9    7.8     5.6   16.7
--             reassembleRFC4180QuotedParts.suffixQuoted Frames.CSV                      src/Frames/CSV.hs:(118,9)-(120,84)          1632   42079341    0.8    0.0     1.4    0.0
--              ==                                       Data.Text                       Data/Text.hs:(324,5)-(326,30)               1633   42079341    0.7    0.0     0.7    0.0
--               aBA                                     Data.Text.Array                 Data/Text/Array.hs:84:7-9                   1634   84158682    0.0    0.0     0.0    0.0
--             reassembleRFC4180QuotedParts.prefixQuoted Frames.CSV                      src/Frames/CSV.hs:(115,9)-(117,81)          1619   42055641    2.3    8.9     2.3    8.9
--              shiftR                                   Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1631   42103041    0.0    0.0     0.0    0.0
--            reassembleRFC4180QuotedParts.finish        Frames.CSV                      src/Frames/CSV.hs:(128,9)-(129,54)          1635    6004563    0.0    0.0     0.0    0.0
--            reassembleRFC4180QuotedParts.quoteText     Frames.CSV                      src/Frames/CSV.hs:122:9-41                  1621    6004563    0.1    0.0     0.7    0.7
--             singleton_                                Data.Text.Show                  Data/Text/Show.hs:(81,1)-(88,18)            1622    6004563    0.3    0.5     0.7    0.7
--              run                                      Data.Text.Array                 Data/Text/Array.hs:178:1-34                 1624    6004563    0.1    0.1     0.3    0.3
--               singleton_.x                            Data.Text.Show                  Data/Text/Show.hs:(83,9)-(85,25)            1625          0    0.2    0.2     0.2    0.2
--                shiftL                                 Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1626    6004563    0.0    0.0     0.0    0.0
--                shiftR                                 Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1629    6004563    0.0    0.0     0.0    0.0
--              singleton_.d                             Data.Text.Show                  Data/Text/Show.hs:88:9-18                   1628    6004563    0.0    0.0     0.0    0.0
--              singleton_.len                           Data.Text.Show                  Data/Text/Show.hs:(86,9)-(87,31)            1627    6004563    0.0    0.0     0.0    0.0
--              singleton_.x                             Data.Text.Show                  Data/Text/Show.hs:(83,9)-(85,25)            1623    6004563    0.0    0.0     0.0    0.0
--            reassembleRFC4180QuotedParts.prefixQuoted  Frames.CSV                      src/Frames/CSV.hs:(115,9)-(117,81)          1620          0    0.1    0.4     0.1    0.4
--             shiftR                                    Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1630    6004563    0.0    0.0     0.0    0.0
--        headerOverride                                 Frames.CSV                      src/Frames/CSV.hs:60:38-51                  1569          2    0.0    0.0     0.0    0.0
--        hGetLine                                       Data.Text.IO                    Data/Text/IO.hs:169:1-32                    1572          0    0.0    0.0    17.2    5.3
--         hGetLineWith                                  Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(44,1)-(46,79)     1573    6004565    0.4    1.0    17.1    5.3
--          hGetLineWith.go                              Data.Text.Internal.IO           Data/Text/Internal/IO.hs:46:5-79            1574    6004565    0.3    0.3    16.7    4.3
--           hGetLineLoop                                Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(49,1)-(82,42)     1575    6004565    0.1    0.4    15.5    3.2
--            hGetLineLoop.go                            Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(50,2)-(82,42)     1576    6279640    0.6    1.1    15.4    2.8
--             hGetLineLoop.go.findEOL                   Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(51,7)-(56,29)     1577  557024547    2.7    0.2     2.7    0.2
--             unpack                                    Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(93,1)-(102,47)    1578    6279640    0.1    0.2    10.3    1.4
--              unpack.go                                Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(98,3)-(102,47)    1583    6273819    7.1    1.2    10.2    1.2
--               unpack.go.next                          Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(100,5)-(101,44)   1586  557018726    3.1    0.0     3.1    0.0
--                unpack.go.ix                           Data.Text.Internal.IO           Data/Text/Internal/IO.hs:102:5-47           1587  550744907    0.0    0.0     0.0    0.0
--               shiftL                                  Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1584    6273819    0.0    0.0     0.0    0.0
--               shiftR                                  Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1585    6273819    0.0    0.0     0.0    0.0
--             hGetLineLoop.go.buf1                      Data.Text.Internal.IO           Data/Text/Internal/IO.hs:66:11-37           1581     275075    0.0    0.0     0.0    0.0
--             maybeFillReadBuffer                       Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(86,1)-(90,20)     1579     275075    0.0    0.0     1.8    0.1
--              getSomeCharacters                        Data.Text.Internal.IO           Data/Text/Internal/IO.hs:(130,1)-(151,52)   1580     275075    0.0    0.0     1.8    0.1
--               readTextDevice                          Data.Text.Internal.IO           Data/Text/Internal/IO.hs:133:39-64          1582     275075    1.8    0.1     1.8    0.1
--           concat                                      Data.Text                       Data/Text.hs:(894,1)-(906,36)               1612    6004563    0.3    0.0     0.9    0.7
--            concat.ts'                                 Data.Text                       Data/Text.hs:899:5-34                       1613    6004563    0.4    0.5     0.4    0.5
--            concat.go                                  Data.Text                       Data/Text.hs:(902,5)-(906,36)               1714     269254    0.0    0.0     0.0    0.0
--            concat.len                                 Data.Text                       Data/Text.hs:900:5-48                       1718     269254    0.0    0.0     0.1    0.1
--             sumP                                      Data.Text                       Data/Text.hs:(1724,1)-(1729,27)             1722          0    0.0    0.0     0.0    0.0
--              sumP.go                                  Data.Text                       Data/Text.hs:(1725,9)-(1729,27)             1723     807762    0.0    0.0     0.0    0.0
--               sumP.go.ax                              Data.Text                       Data/Text.hs:1728:17-26                     1724     538508    0.0    0.0     0.0    0.0
--            run                                        Data.Text.Array                 Data/Text/Array.hs:178:1-34                 1715     269254    0.0    0.0     0.1    0.1
--             concat.go                                 Data.Text                       Data/Text.hs:(902,5)-(906,36)               1716          0    0.0    0.1     0.1    0.1
--              concat.go.step                           Data.Text                       Data/Text.hs:(904,11)-(905,61)              1726     538508    0.1    0.0     0.1    0.0
--               aBA                                     Data.Text.Array                 Data/Text/Array.hs:84:7-9                   1728     538508    0.0    0.0     0.0    0.0
--               concat.go.step.(...)                    Data.Text                       Data/Text.hs:905:17-26                      1727     538508    0.0    0.0     0.0    0.0
--               maBA                                    Data.Text.Array                 Data/Text/Array.hs:92:7-10                  1729     538508    0.0    0.0     0.0    0.0
--              shiftL                                   Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:60:5-50  1717     269254    0.0    0.0     0.0    0.0
--              shiftR                                   Data.Text.Internal.Unsafe.Shift Data/Text/Internal/Unsafe/Shift.hs:63:5-51  1725     269254    0.0    0.0     0.0    0.0
--       return                                          Pipes.Internal                  src/Pipes/Internal.hs:90:5-17               1730          1    0.0    0.0     0.0    0.0
--      _bind.go.\                                       Pipes.Internal                  src/Pipes/Internal.hs:102:43-56             1589          2    0.0    0.0     0.0    0.0


-- single-threaded
-- stack build --executable-profiling --library-profiling --ghc-options="-O -fprof-auto -rtsopts -ddump-stg -dsuppress-all" && /home/cody/source/minimal-frames-lookup-map/.stack-work/install/x86_64-linux/lts-7.15/8.0.1.20161213/bin/minimal-frames +RTS -p 

-- multi-threaded version
-- stack build --executable-profiling --library-profiling --ghc-options="-O -threaded -fprof-auto -rtsopts" &&  .stack-work/install/x86_64-linux/lts-7.15/8.0.1.20161213/bin/minimal-frames-lookup-map +RTS -N4 -p


  cp minimal-frames-lookup-map.ps minimal-frames-lookup-map_hd.ps
cp minimal-frames-lookup-map.ps  minimal-frames-lookup-map_hy.ps

