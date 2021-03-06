# AcousticParametersforVowelsExtractor.psc
# Script implemented by Plinio A. Barbosa (IEL/Unicamp) 
#Copyright (c) December 2015
form Aquisição dos arquivos
 word AudioFile Test.wav
 word TGFile Test.TextGrid
 word OutFile TestOut
 positive SEThreshold 400
 integer VowelTier 2
 positive NFormant 5
 positive MaxFormant 5000 (= 5500 for females)
endform
Read from file... 'audioFile$'
filenameSound$ = selected$("Sound")
Resample... 11000 50
Rename... VowelFile
To Formant (burg)... 0 'nFormant' 'maxFormant' 0.025 50
Rename... FormantTrack
Create Table with column names... 'outFile$' 1 Vowel  Dur F1 F2 SE
row = 1
Read from file... 'tGFile$'
filenameTG$ = selected$("TextGrid")
nvowelTierIntervals = Get number of intervals... 'vowelTier'
for i from 1 to nvowelTierIntervals -1
  select TextGrid 'filenameTG$'
  vowellabel$ = Get label of interval... 'vowelTier' 'i'
  if vowellabel$ <> ""
      start = Get starting point... 'vowelTier' 'i'
      end = Get end point... 'vowelTier' 'i'
      dur = round(('end'-'start')*1000)
      middur = ('end'+'start')/2
      select Formant FormantTrack
      f1 = Get value at time... 1 'middur' Hertz Linear
      f2 = Get value at time... 2 'middur' Hertz Linear
      select Sound VowelFile
      Extract part... 'start' 'end' rectangular 1.0 yes
      To Spectrum... yes
      se = Get band energy difference... 0 'sEThreshold' 0 0
      select Table 'outFile$'
      Set string value... 'row' Vowel 'vowellabel$'
      Set numeric value... 'row' Dur 'dur:0'
      if f1 == undefined
       Set string value... 'row' F1 NA
      else 
        Set numeric value... 'row' F1 'f1:0'
      endif
      if f2 == undefined
       Set string value... 'row' F2 NA
      else 
        Set numeric value... 'row' F2 'f2:0'
      endif
      Set numeric value... 'row' SE 'se:1'
      Append row
      row = row + 1
      select TextGrid 'filenameTG$'
     endif
endfor
out$ = outFile$ + ".txt"
select Table 'outFile$'
Remove row... 'row'
Save as tab-separated file... 'out$'
#/i/ Reference
select Table 'outFile$'
Extract rows where column (text)... F1 "is not equal to" NA
Extract rows where... self$["Vowel"]="i" or  self$["Vowel"]="e"  or  self$["Vowel"]="eh" or  self$["Vowel"]="a" or  self$["Vowel"]="oh" or  self$["Vowel"]="o" or  self$["Vowel"]="u" 
meanF1 = Get mean... F1
sdF1 = Get standard deviation... F1
select Table 'outFile$'
Extract rows where column (text)... F2 "is not equal to" NA
Extract rows where... self$["Vowel"]="i" or  self$["Vowel"]="e"  or  self$["Vowel"]="eh" or  self$["Vowel"]="a" or  self$["Vowel"]="oh" or  self$["Vowel"]="o" or  self$["Vowel"]="u" 
meanF2 = Get mean... F2
sdF2 = Get standard deviation... F2
select Table 'outFile$'
nrowsfinaltable = Get number of rows
for i from 1 to nrowsfinaltable
	vow$ = Get value... 'i' Vowel
		f1 = Get value... 'i' F1
		temp$ = string$(f1)
		if temp$ <> "NA"
			f1z = (f1-meanF1)/sdF1
			Set numeric value... 'i' F1 'f1z:3'
		endif
		f2 = Get value... 'i' F2
		temp$ = string$(f2)
		if temp$ <> "NA"
			f2z = (f2-meanF2)/sdF2
			Set numeric value... 'i' F2 'f2z:3'
		endif
endfor
outFilenorm$ = outFile$ + "norm"
temp$ = outFilenorm$+".txt"
Save as tab-separated file... 'temp$'
#select all
#Remove