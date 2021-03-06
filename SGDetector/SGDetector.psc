# SGdetector.psc
# Script implemented by Plinio A. Barbosa (IEL/Unicamp) for detecting
# stress group boundaries from production criteria, namely VV durations.
# Input: previously segmented VV intervals or phones (TextGrid)
# Please, do not distribute without the author's previous authorisation
# The TextGrid and Reference-statistics (xy.TableOfReal, where xy = BP, EP, F, G, or BE) files need to be in the 
# same directory!!! 
# Date: May 27th, 2004. New version Jul 2016, Jul 2020
form File acquisition
 word File_(TextGrid) InputFile
 boolean VvTier 1
 integer Tier 1
 choice Reference: 1
   button BP
   button SP
   button EP
   button G
   button F
   button BE
 choice PhoneticAlphabet 2
   button Sampa
   button Other
 boolean DrawLines 1
endform
# Lê o arquivo de referencia com as triplas (segmento, média, desvio-padrão) do locutor
# Referencia. A variável nseg contém o número total de segmentos do arquivo de referência
Read from file... 'reference$'.TableOfReal
nseg = Get number of rows
#
# Lê arquivo e TextGrid (desde q tenha o mesmo nome do arquivo de som
arq$ = file$ + ".TextGrid"
Read from file... 'arq$'
begin = Get starting time
end = Get finishing time
totaldur = end - begin
nselected = Get number of intervals... 'tier'
arqout$ = file$ + "dur" + ".txt"
filedelete 'arqout$'
arqoutstrgrp$ = file$ + "SG" + ".txt"
filedelete 'arqoutstrgrp$'
fileappend 'arqout$' Vv dur z smoothz bound 'newline$'
fileappend 'arqoutstrgrp$' durSG nVV 'newline$'
select TextGrid 'file$'
initialtime = Get starting point... 'tier' 2
# If segmentation is made in VV units
if vvTier = 1
 nselected = nselected - 2
 nVV = nselected
 for i from 1 to nselected
  adv = i + 1
  nome$ = Get label of interval... 'tier' 'adv'
 itime = Get starting point... 'tier' 'adv'
 ftime = Get end point... 'tier' 'adv'
 dur = ftime - itime
 dur = dur*1000
 tint = Get starting point... 'tier' 'adv'
 call zscorecomp 'nome$' 'dur' 'tint'
 dur'i' = dur
 z'i' = z
 nome'i'$ = nome$
 select TextGrid 'file$'
 adv = i + 1
endfor
smz1 = (2*z1 + z2)/3
deriv1 = smz1
smz2 = (2*z2 + z1)/3
deriv2 = smz2 - smz1
i = 3
if smz1 < smz2
 minsmz = smz1
 maxsmz = smz2
else
 minsmz = smz2
 maxsmz = smz1
endif
while i <= (nselected-2)
 del1 = i - 1
 del2 = i - 2
 adv1 = i + 1
 adv2 = i + 2
 smz'i' = (5*z'i' + 3*z'del1' + 3*z'adv1' + z'del2' + 1*z'adv2')/13
 deriv'i' = smz'i' - smz'del1'
 if smz'i' < minsmz
  minsmz = smz'i'
 endif
 if smz'i' > maxsmz
  maxsmz = smz'i'
 endif
 i = i + 1
endwhile
tp1 = nselected -1
tp2 = nselected -2
smz'tp1' = (3*z'tp1'+ z'tp2' + z'nselected')/5
deriv'tp1' = smz'tp1' - smz'tp2'
 if smz'tp1' < minsmz
  minsmz = smz'tp1'
 endif
 if smz'tp1' > maxsmz
  maxsmz = smz'tp1'
 endif
smz'nselected' = (2*z'nselected' + z'tp1')/3  
deriv'nselected' = smz'nselected' - smz'tp1'
 if smz'nselected' < minsmz
  minsmz = smz'nselected' 
 endif
 if smz'nselected' > maxsmz
  maxsmz = smz'nselected' 
 endif
tempfile$ = "temp.TableOfReal"
filedelete 'tempfile$'
fileappend 'tempfile$' File type = "ooTextFile short" 'newline$'
fileappend 'tempfile$' "TableOfReal"  'newline$'
fileappend 'tempfile$'  'newline$'
fileappend 'tempfile$' 2 'newline$'
fileappend 'tempfile$' columnLabels []:  'newline$'
fileappend 'tempfile$' "position" "smoothed z" 'newline$'
tpp = nselected + 2
fileappend 'tempfile$' 'tpp' 'newline$'
time = initialtime
fileappend 'tempfile$' row[1]: "0" 0.0 0.0 'newline$'
boundcount = 0
sdur = 0
ssyl = 0
sdurSG = 0
svar = 0
for i from 1 to nselected
 tempsmz = smz'i'
 tpnome$ = nome'i'$
 adv1 = i + 1
 btime'i' = 0
 time = time + dur'i'/1000
 time'i' = time
 fileappend 'tempfile$' row['adv1']: "'tpnome$'" 'time:3' 'tempsmz:3' 'newline$'
 if i <> nselected 
  adv1 = i + 1
  if (deriv'i' >= 0) and (deriv'adv1' < 0)
    boundary = 1
    boundcount = boundcount + 1
    btime'i' = time
    bctime'boundcount' = time 
    smzbound'boundcount' = smz'i'
  else
    boundary = 0
  endif
 else
  del1 = i -1 
  if smz'i' > smz'del1'
     boundary = 1
     boundcount = boundcount + 1
     btime'i' = time 
     bctime'boundcount' = time 
     smzbound'boundcount' = smz'i'
  else 
    boundary = 0
  endif
 endif
 tempz = z'i'
 tempdur = dur'i'
 sdur = sdur + tempdur
 sdurSG = sdurSG + tempdur
 ssyl = ssyl + 1
 fileappend 'arqout$' 'tpnome$' 'tempdur:0' 'tempz:2' 'tempsmz:2' 'boundary' 'newline$'
 if boundary == 1
  fileappend 'arqoutstrgrp$' 'sdurSG:0' 'ssyl' 'newline$'
  sdurSG = 0
  ssyl = 0
 endif
endfor
meandur = sdur/nselected
for i from 1 to nselected
svar = svar + (dur'i' - meandur)^2
endfor
stddevdur = sqrt(svar/(nselected - 1))
# If segmentation is made in phones
else
 time = initialtime
 i = 1
 cptVV = 1
 repeat
  i = i + 1 
  phone$ = Get label of interval... 'tier' 'i'
  nome$ = phone$
  firstidentifier$ = mid$(phone$,1,1)
  if firstidentifier$ == """" or firstidentifier$ == "'"
    firstidentifier$ = mid$(phone$,2,1)
  endif
  call isvowel 'firstidentifier$'
  if truevowel = 0
   initialtime = Get end point... 'tier' 'i'
  endif
 until truevowel= 1
 repeat
  sumofvar = 0
  sumofdur = 0
  znum = 0
  repeat
   select TextGrid 'file$'
   itime = Get starting point... 'tier' 'i'
   ftime = Get end point... 'tier' 'i'
   dur = ftime - itime
   dur = round(dur*1000)
   nexti = i + 1
   nextphone$ = Get label of interval... 'tier' 'nexti'
   if nextphone$ = "#" or nextphone$ = "_" or nextphone$ = "-"
    itime = Get starting point... 'tier' 'nexti'
    ftime = Get end point... 'tier' 'nexti'
    dur = dur + round((ftime - itime)*1000)
    i = i + 1
  endif
  select all
  j = 1
  terminate = 0
  tableID = selected ("TableOfReal")
  select 'tableID'
  while (j <= nseg) and  not terminate
     label$ =  Get row label... 'j'
     if phone$ == label$
         terminate = 1
         mean = Get value... 'j' 1
         sd   = Get value... 'j' 2
         sumofvar= sd*sd + sumofvar
     endif
     j = j+1
   endwhile
   if not terminate
    exit Didn't find phone 'phone$'. Correct TableOfReal file
   endif
   znum = znum + (dur - mean)
   sumofdur = sumofdur + dur
   i = i + 1 
   if i < nselected
     select TextGrid 'file$'
     phone$ =  Get label of interval... 'tier' 'i'
     firstidentifier$ = mid$(phone$,1,1)
     call isvowel 'firstidentifier$'
     if truevowel = 0
       nome$ = nome$ + phone$
     endif
   endif
 until (truevowel = 1) or (i >= nselected)
 dur'cptVV' = sumofdur
 z'cptVV' = znum/sqrt(sumofvar)
 nome'cptVV'$ = nome$
  nome$ = phone$
  cptVV = cptVV + 1
  select TextGrid 'file$'
 until i >= nselected
 nVV = cptVV - 1
 smz1 = (2*z1 + z2)/3
 deriv1 = smz1
 smz2 = (2*z2 + z1)/3
 deriv2 = smz2 - smz1
 i = 3
 if smz1 < smz2
  minsmz = smz1
  maxsmz = smz2
 else
  minsmz = smz2
  maxsmz = smz1
 endif
 while i <= (nVV-2)
  del1 = i - 1
  del2 = i - 2
  adv1 = i + 1
  adv2 = i + 2
  smz'i' = (5*z'i' + 3*z'del1' + 3*z'adv1' + z'del2' + 1*z'adv2')/13
 deriv'i' = smz'i' - smz'del1'
 if smz'i' < minsmz
  minsmz = smz'i'
 endif
 if smz'i' > maxsmz
  maxsmz = smz'i'
 endif
 i = i + 1
 endwhile
 tp1 = nVV -1
 tp2 = nVV -2
 smz'tp1' = (3*z'tp1'+ z'tp2' + z'nVV')/5
 deriv'tp1' = smz'tp1' - smz'tp2'
 if smz'tp1' < minsmz
  minsmz = smz'tp1'
 endif
 if smz'tp1' > maxsmz
  maxsmz = smz'tp1'
 endif
 smz'nVV' = (2*z'nVV' + z'tp1')/3  
 deriv'nVV' = smz'nVV' - smz'tp1'
 if smz'nVV' < minsmz
  minsmz = smz'nVV' 
 endif
 if smz'nVV' > maxsmz
  maxsmz = smz'nVV' 
 endif
 tempfile$ = "temp.TableOfReal"
 filedelete 'tempfile$'
 fileappend 'tempfile$' File type = "ooTextFile short" 'newline$'
 fileappend 'tempfile$' "TableOfReal"  'newline$'
 fileappend 'tempfile$'  'newline$'
 fileappend 'tempfile$' 2 'newline$'
 fileappend 'tempfile$' columnLabels []:  'newline$'
 fileappend 'tempfile$' "position" "smoothed z" 'newline$'
 tpp = nVV + 2
 fileappend 'tempfile$' 'tpp' 'newline$'
 fileappend 'tempfile$' row[1]: "0" 0.0 0.0 'newline$'
 boundcount = 0
 sdur = 0
 ssyl = 0
 sdurSG = 0
 svar = 0
 time = initialtime
 for i from 1 to nVV
  tempsmz = smz'i'
  tpnome$ = nome'i'$
  adv1 = i + 1
#  btime'i' = 0
  time = time + dur'i'/1000
  time'i' = time
  fileappend 'tempfile$' row['adv1']: "'tpnome$'" 'time:3' 'tempsmz:3' 'newline$'
  if i <> nselected
   adv1 = i + 1
   if (deriv'i' >= 0) and (deriv'adv1' < 0)
    boundary = 1
    boundcount = boundcount + 1
    btime'i' = time
    bctime'boundcount' = time 
    smzbound'boundcount' = smz'i'
   else
    boundary = 0
   endif
  else
   del1 = i -1 
   if smz'i' > smz'del1'
     boundary = 1
     boundcount = boundcount + 1
     btime'i' = time 
     bctime'boundcount' = time 
     smzbound'boundcount' = smz'i'
   else 
    boundary = 0
   endif
  endif
  tempz = z'i'
  tempdur = dur'i'
  sdur = sdur + tempdur
  sdurSG = sdurSG + tempdur
  ssyl = ssyl + 1
  fileappend 'arqout$' 'tpnome$' 'tempdur:0' 'tempz:2' 'tempsmz:2' 'boundary' 'newline$'
  if boundary == 1
   fileappend 'arqoutstrgrp$' 'sdurSG:0' 'ssyl' 'newline$'
   sdurSG = 0
   ssyl = 0
  endif
 endfor
 meandur = sdur/nVV
 for i from 1 to nVV
  svar = svar + (dur'i' - meandur)^2
 endfor
 stddevdur = sqrt(svar/(nVV - 1))
endif
tp = i+1
fileappend 'tempfile$' row['tp']: "X" 'end' 0 'newline$'
select all
Remove
if drawLines = 1
 Black
 Axes... 0 1 -1 1
 for i from 1 to nVV-1 
  tm = time'i'/totaldur
  if abs(minsmz) > abs(maxsmz)
     maxsmz = abs(minsmz)
  else 
     maxsmz = abs(maxsmz)
  endif 
  smzz = smz'i'/maxsmz 
  j = i+1
  tmnext = time'j'/totaldur
  smzznext = smz'j'/maxsmz 
  Draw line... 'tm' 'smzz' 'tmnext' 'smzznext'
 endfor
endif
#  Write a TextGrid with the stress group boundaries
fileout$ = file$ + "SG.TextGrid"
filedelete 'fileout$'
fileappend 'fileout$' File type = "ooTextFile short" 'newline$'
fileappend 'fileout$' "TextGrid" 'newline$'
fileappend 'fileout$' 'newline$'
fileappend 'fileout$' 'begin' 'newline$'
fileappend 'fileout$' 'end' 'newline$'
fileappend 'fileout$' <exists> 'newline$'
fileappend 'fileout$' 2 'newline$'
fileappend 'fileout$' "TextTier" 'newline$'
fileappend 'fileout$' "BoundDegree" 'newline$'
fileappend 'fileout$' 'begin' 'newline$'
fileappend 'fileout$' 'end' 'newline$'
fileappend 'fileout$' 'boundcount' 'newline$'
for i from 1 to boundcount
 temp = bctime'i'
 fileappend 'fileout$' 'temp' 'newline$'
 tmpzb = round(100*smzbound'i')/100
 lab$ = string$(tmpzb)
 fileappend 'fileout$' "'lab$'" 'newline$'
endfor
fileappend 'fileout$' "IntervalTier" 'newline$'
fileappend 'fileout$' "StressGroups" 'newline$'
fileappend 'fileout$' 'begin' 'newline$'
fileappend 'fileout$' 'end' 'newline$'
tmp = boundcount + 2
fileappend 'fileout$' 'tmp' 'newline$'
fileappend 'fileout$' 0.00 'newline$'
fileappend 'fileout$' 'initialtime' 'newline$'
fileappend 'fileout$' "" 'newline$'
temp = initialtime
for i from 1 to boundcount
 fileappend 'fileout$' 'temp' 'newline$'
 temp = bctime'i'
 lab$ = "SG" + string$(i)
 fileappend 'fileout$' 'temp' 'newline$'
 fileappend 'fileout$' "'lab$'" 'newline$'
endfor
fileappend 'fileout$' 'temp' 'newline$'
fileappend 'fileout$' 'end' 'newline$'
fileappend 'fileout$' "" 'newline$'
arqgrid1$ = file$ + ".TextGrid"
Read from file... 'arqgrid1$'
Read from file... 'fileout$'
plus TextGrid 'file$'
Merge
filedelete temp.TableOfReal
##
procedure zscorecomp nome$ dur tint
 sizeunit = length (nome$)
 sumofmeans = 0
 sumofvar = 0
 cpt = 1
 while cpt <= sizeunit
  nb = 1
  terminate = 0
  seg$ = mid$(nome$,cpt,1)
  if cpt < sizeunit
    if phoneticAlphabet$ = "Other"
     if reference$ = "BP" or reference$ = "EP"
      if mid$(nome$,cpt+1,1) == "h"  or mid$(nome$,cpt+1,1) == "N"
         nb = nb + 1
         seg$ = seg$ + mid$(nome$,cpt+1,1)
      endif
      if (cpt+nb <= sizeunit)
       tp$ = mid$(nome$,cpt,1)
       call isvowel 'tp$'
       if ((mid$(nome$,cpt+nb,1) = "I")  or  (mid$(nome$,cpt+nb,1)  = "U"))  and truevowel
         seg$ = seg$ + mid$(nome$,cpt+nb,1)
         nb= nb+1
       endif
      endif
     endif
###
     if reference$ = "F"
       if mid$(nome$,cpt+1,1) == "h"  or mid$(nome$,cpt+1,1) == "N"  or mid$(nome$,cpt+1,1) == "x"
         nb = nb + 1
         seg$ = seg$ + mid$(nome$,cpt+1,1)
      endif
     endif
###
	if reference$ = "G"
       if mid$(nome$,cpt+1,1) == ":"  or mid$(nome$,cpt+1,1) == "N"  or mid$(nome$,cpt+1,1) == "x"
         nb = nb + 1
         seg$ = seg$ + mid$(nome$,cpt+1,1)
      endif
     endif
###
	if reference$ = "BE"
       if mid$(nome$,cpt+1,1) == "h"  or mid$(nome$,cpt+1,1) == "H"  or mid$(nome$,cpt+1,1) == ":" or mid$(nome$,cpt+1,1) == "e"  or mid$(nome$,cpt+1,1) == "R" or mid$(nome$,cpt+1,1) == "I"  or mid$(nome$,cpt+1,1) == "U" or mid$(nome$,cpt+1,1) == "S"  or mid$(nome$,cpt+1,1) == "Z"
         nb = nb + 1
         seg$ = seg$ + mid$(nome$,cpt+1,1)
      endif
     endif
###
	if reference$ = "SP"
       if mid$(nome$,cpt+1,1) == "j"  or mid$(nome$,cpt+1,1) == "h" or mid$(nome$,cpt+1,1) == "r"
         nb = nb + 1
         seg$ = seg$ + mid$(nome$,cpt+1,1)
      endif
     endif
###
     endif
    else
      if mid$(nome$,cpt+1,1) == "~"
         nb = nb + 1
         seg$ = seg$ + mid$(nome$,cpt+1,1)
      endif
      if (cpt+nb <= sizeunit)
       tp$ = mid$(nome$,cpt,1)
       call isvowel 'tp$'
       if ((mid$(nome$,cpt+nb,1) = "j")  or  (mid$(nome$,cpt+nb,1)  = "w"))  and truevowel
         seg$ = seg$ + mid$(nome$,cpt+nb,1)
         nb= nb+1
       endif
      endif
    endif
  endif    
  j = 1
  select all
  tableID = selected ("TableOfReal")
  select 'tableID'
  while (j <= nseg) and  not terminate
     label$ =  Get row label... 'j'
     if seg$ = label$
         terminate = 1
         mean = Get value... 'j' 1
         sd      = Get value... 'j' 2
         sumofmeans = mean + sumofmeans
         sumofvar= sd*sd + sumofvar
     endif
     j = j+1
  endwhile
  if not terminate
   exit Didn't find phone 'seg$' at 'tint'. Pls check the file TableOfReal
  endif
  cpt= cpt+nb
 endwhile
z = (dur - sumofmeans)/sqrt(sumofvar)
endproc
procedure isvowel temp$
 truevowel = 0
 if temp$ = "i" or  temp$ = "e"  or temp$ = "^"  or temp$ = "a"  or temp$ = "o"  or temp$ = "u" or temp$ = "I" or temp$ = "E"
    ...or temp$ = "A"  or temp$ = "y" or temp$ = "O"  or temp$ = "U" or temp$ = "6"  or temp$ = "@"
    ...or temp$ = "2" or temp$ = "9" or temp$ = "Y" or temp$ = "Ä" or temp$ = "Å" or temp$ = "Ö" or temp$ = "x"
    truevowel = 1
 endif
endproc 
