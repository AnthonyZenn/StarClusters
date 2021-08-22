pro llfinal

;This program is written to work with the Vizier.txt file

;This file contains ~ 178,000 stars all with B,V,and I errors
;less than or equal to 0.05 mag

;The user can choose to select stars based on b-v magnitude, the
;user also must input a minimum and max clustering length, as well 
;step length.  The program then runs and finds the number of groups 
;determined by spatial distance along the sky and clustering length.
;A group contains at least three stars, but it is easy to adjust this
;number by editing very little of the program.

;Two output files are created, the first being a simple output of 
;clustering lengths and the number of groups.  The second file
;contains a list of every group and its stars, and these groups
;are the groups for the clustering length that contained the max
;number of groups.  The file lists a star's number, which is simply
;the position of the star in the list of stars that were used in
;the program - for instance '100' means that it was the 100th star
;saved by the program.  So the file lists a starnumber, then another
;starnumber, until it lists all the starnumbers in the group, then 
;prints '0', and lists all the starnumbers from the next group, prints
;'0', and so on.

;This program was written to be formatted with the Vizier.txt file.  If
;changes were to be made to adapt this program to other files, then
;these aspects of the program need to be adjusted:

;  file input, and the data acquiring procedure
;  the conversion of data to RA and dec in arcseconds and radians
;  the clustering length values will need to calibrated

;the groupfinding procedure should still work in principle as long as
;these adjustments are made

file=string('')
outfile=string('')
outfile2=string('')

file='Vizier.txt'
outfile='outllfinal.txt'
outfile2='outllfinalg.txt'

bvmag=0.0
choice=0.0

read,choice,prompt='Want to choose B-V for stars?  1=yes  2=no     '

if choice eq 1 then begin

read,bvmag,prompt='Enter B-V value for stars to include (also keeps brighter stars):   '

endif

if choice eq 2 then bvmag=99999.9
;this value should allow all stars to be included

maxd=0.0
mind=0.0
step=1.0
iters=1

read,mind,prompt='Enter min clustering length in parsecs:   '
read,maxd,prompt='Enter max clustering length in parsecs:   '
read,step,prompt='Enter step length in parsecs:             '

iters=(maxd-mind)/step+1

print,'min clustering length:  ',mind,' pc'
print,'max clustering length:  ',maxd,' pc'
print,'step length:            ',step,' pc'
print,'number of iterations:   ',iters

col=15.0
;15 columns in Vizier file
;this number isn't actually used, but it's useful to know

m=numlines(file)
; m = total number of stars in the input file

openr,one,file,/get_lun
;opens input file and gets it ready to read data

red=fltarr(m)
;This array is used to store the V-R values for each star

xx1=fltarr(m)
xx2=fltarr(m)
xx3=fltarr(m)
yy1=fltarr(m)
yy2=fltarr(m)
yy3=fltarr(m)

fxx1=fltarr(m)
fxx2=fltarr(m)
fxx3=fltarr(m)
fyy1=fltarr(m)
fyy2=fltarr(m)
fyy3=fltarr(m)

;The above arrays are used to store the RA and dec values for each star
;The 'f' arrays are used for finding the endpoints for the cells when
;the linked list is created

x1=0.0
x2=0.0
x3=0.0
y1=0.0
y2=0.0
y3=0.0
;these values store the RA and dec for a star to be read into an array

j=0.0
;dummy variable used as a placeholder

n=0.0
;this value will be the number of useful stars - the stars left after the
;'while' and 'if' statements below filter out the other ones

blue=0.0
blueerror=0.0
visual=0.0
visualerror=0.0
infrared=0.0
infrarederror=0.0


fcount=0.0
count=0.0
;fcount used to store all star data for endpoint calculation for linked list
;the 'count' value increases as the number of stars that meet certain criteria in
;the 'if' statement below increases, it will equal the number of good stars
;to use in the rest of the program

while (not eof(one)) do begin

readf,one,j,x1,x2,x3,y1,y2,y3,j,j,blue,blueerror,visual,visualerror,infrared,infrarederror

    fxx1(fcount)=x1
    fxx2(fcount)=x2
    fxx3(fcount)=x3
    fyy1(fcount)=y1
    fyy2(fcount)=y2
    fyy3(fcount)=y3
    fcount=fcount+1

   if (blue-visual) le bvmag then begin

    xx1(count)=x1
    xx2(count)=x2
    xx3(count)=x3
    yy1(count)=y1
    yy2(count)=y2
    yy3(count)=y3
    count=count+1


     endif

  n=count
;  n=number of stars the program will use

endwhile

;The above 'while' and nested 'if' statement basically reads in data from the input
;file, and determines if a star meets the criteria in the 'if' statement.  If a
;star meets the correct criteria, then its RA and dec values are stored in an array,
;otherwise the program moves onto the next star, until all the stars in the input file
;are read.  The 'count' is the number of stars that meet the criteria in the 'if'
;statement, and each star's RA and dec values are stored sequentially


print,'Number of stars used:  ',n
print,'Total number of stars in file:  ', m


x=fltarr(n+1)
y=fltarr(n+1)
yrad=fltarr(n+1)


for h=1L,n do begin

  y(h)=(-yy1(h-1)+(60.0*yy2(h-1)+yy3(h-1))/3600.0)*3600.0
  yrad(h)=y(h)/206264.8
  x(h)=((xx1(h-1)+(60.0*xx2(h-1)+xx3(h-1))/3600.0)/24.0)*360.0*3600.0*cos(y(h))
  ;stores RA and dec in arrays converted to arcseconds or radians
  ;The minus sign in front of yy1 used to keep everything positive (yy1 < 0 for Vizier.txt)
  ;cosine factor takes dec into account for RA position (dec 90 degrees => RA equals 0)
  ;x=RA arcsecs   y=dec arcsecs  yrad=dec radians
  ;'1' value in arrays indicate first star in array

  endfor
x(0)=-999999
y(0)=-999999

fx=fltarr(m+1)
fy=fltarr(m+1)
fyrad=fltarr(m+1)

for h=1L,m do begin

  fy(h)=(-fyy1(h-1)+(60.0*fyy2(h-1)+fyy3(h-1))/3600.0)*3600.0
  fyrad(h)=fy(h)/206264.8
  fx(h)=((fxx1(h-1)+(60.0*fxx2(h-1)+fxx3(h-1))/3600.0)/24.0)*360.0*3600.0*cos(fy(h))
  ;same as above, except this is all stars data and is used to calculate endpoints
  ;'1' value in arrays indicate first star in array

  endfor
fx(0)=-999999
fy(0)=-999999

highRA=fx(1)
lowRA=fx(1)
highdec=fy(1)
lowdec=fy(1)

for i=1L,m do begin

if highRA lt fx(i) then highRA=fx(i)
if lowRA gt fx(i) then lowRA=fx(i)
if highdec lt fy(i) then highdec=fy(i)
if lowdec gt fy(i) then lowdec=fy(i)

endfor

;The above routine determines the min and max values for RA and dec


xcal=10/(highRA-lowRA)
ycal=10/(highdec-lowdec)
;based on max/min RA and dec values for all stars
;used to calibrate values to create the linked list


lhoca=fltarr(101)
ll=fltarr(n+1)
ll(*)=0
lhoca(*)=0

for k=1L,n do begin

i1=nint(((x(k)-lowRA)*xcal)-0.5)
i2=nint(((y(k)-lowdec)*ycal)-0.5)

if x(k) eq lowRA then i1=0
if x(k) eq highRA then i1=9
if y(k) eq lowdec then i2=0
if y(k) eq highdec then i2=9

ihoc=1+i1+i2*10
inext=lhoca(ihoc)

ll(k)=inext
lhoca(ihoc)=k

endfor

;All the x(k) values are associated with RA, and i1 will vary between 0 and 9
;All the y(k) values associated with dec, and i2 varies between 0 and 9
;i2 gets multiplied by 10 in next line, so it now varies between 0 and 90
;ihoc will now vary between 1 and 100
;Since ihoc varies between 1 and 100, every star's position will be linked to 
;a number 1-100, and they are linked by position in lhoca array and linked list


npcmx=0.0
npcmn=9999.9

for j=1,100 do begin

npc=0.0
illl=lhoca(j)

  while (illl ne 0) do begin

    npc=npc+1
    illl=ll(illl)
  endwhile

  if (npc gt npcmx) then begin
    npcmx=npc
  endif
  if (npc lt npcmn) then begin 
    npcmn=npc
  endif

endfor

print,'largest chain cell has ',npcmx
print,'smallest chain cell has ',npcmn

;The above routine just prints out the min and max of the stars in all
;the cells



print,'now do groupfinding'
;The groupfinding procedure works by cycling through all 100 cells
;It cycles through each cell one at a time, and it compares the positions
;of the stars in each cell with each of the stars in its neighbor cells, but the neighbor
;cells are only forward positions, so no cell is searched twice.


ighoc=fltarr(n+1)
ipll=fltarr(n+1)
ipgrp=fltarr(n+1)
khc=fltarr(npcmx+1)
knc=fltarr(npcmx+1)
;the 'i' arrays store group data through linked list, and
;the 'k' arrays store starnumbers for groupfinding procedure

mghoc=fltarr(n+1)
mpll=fltarr(n+1)
maxng=0.0
;the 'm' arrays are just used to store max group data to be stored in
;output file


offset=intarr(6)

offset(0)=0
offset(1)=1
offset(2)=10
offset(3)=11
offset(4)=-9
offset(5)=9
;these offsets are the positions of neighbor cells, the first cell is itself

totalclust=fltarr(2,iters)
;stores final group data

for d=0L,iters-1 do begin

dist=mind*3.4
rcut=step*d*3.4+dist
rcutsq=rcut*rcut
;the 3.4 is a conversion factor from pc to arcsecs for the SMC
;clustering length iterates, rcutsq is clustering length squared in arcsecs

ipgrp(*)=0
ipll(*)=0
ighoc(*)=0
ig=0.0
nhctot=0.0
;the group data is reset for each clustering length iteration

for k=1L,100 do begin

  lhhoc=k
  nhc=0
  il=lhoca(lhhoc)
  if (il eq 0) then goto, fivefifty
  fiveten: nhc=nhc+1
  khc(nhc)=il
  il=ll(il)
  if (il ne 0) then goto, fiveten
  nhctot=nhctot+nhc
  ;The above routine stores all stars from a given cell, eventually cycles 
  ;thru all cells

  for f=0,5 do begin

    if k eq 10 or k eq 20 or k eq 30 or k eq 40 or k eq 50 or k eq 60 or k eq 70 or k eq 80 or k eq 90 and f eq 1 then goto, fivethirty
    if k eq 10 or k eq 20 or k eq 30 or k eq 40 or k eq 50 or k eq 60 or k eq 70 or k eq 80 or k eq 90 and f eq 3 then goto, fivethirty
    if k eq 10 or k eq 20 or k eq 30 or k eq 40 or k eq 50 or k eq 60 or k eq 70 or k eq 80 or k eq 90 and f eq 4 then goto, fivethirty
    if k eq 1 or k eq 11 or k eq 21 or k eq 31 or k eq 41 or k eq 51 or k eq 61 or k eq 71 or k eq 81 or k eq 91 and f eq 5 then goto, fivethirty
    if k gt 90 and f eq 2 or f eq 3 or f eq 5 then goto, fivethirty
    if k lt 11 and f eq 4 then goto, fivethirty
    if k eq 100 and f ne 0 then goto, fivethirty

    ;the if statements above just check to make sure neighbor cell position isn't past endpoints

    lnhoc=offset(f)+k
    nnc=0
    il=lhoca(lnhoc)
    if (il eq 0) then goto, fivethirty
    fivetwenty: nnc=nnc+1
    knc(nnc)=il
    il=ll(il)
    if (il ne 0) then goto, fivetwenty

    ;the above routine stores stars from a neighbor cell into knc arrary

      for jh=1L,nhc do begin

        kh=khc(jh)
        xd1=x(kh)
        yd1=y(kh)

        if (ipgrp(kh) eq 0) then begin
       
          ig=ig+1
          ighoc(ig)=kh
          ipgrp(kh)=ig
          ihg=ig
        endif else begin
          ihg=ipgrp(kh)
        endelse

        ;routines above store a star's position and its group info

        if (lhhoc eq lnhoc) then begin
          jnbeg=jh+1
        endif else begin
          jnbeg=1.0
        endelse

        ;the above routine improves efficiency in cycling thru stars

        ;the routine belows cycles through neighbor cell stars and compares
        ;position to star position stored earlier

        for jn=jnbeg,nnc do begin

          kn=knc(jn)
          if (ipgrp(kn) eq ihg) then goto, fivetwentyfive
          ;checks to see if star was previously stored

          xd2=x(kn)
          yd2=y(kn)
          dx=xd2-xd1
          dy=yd1-yd2
          r2=dx*dx+dy*dy
          
          if (r2 gt rcutsq) then goto, fivetwentyfive
          ;above is distance calc

          if (ipgrp(kn) eq 0) then begin

            ipgrp(kn)=ihg
            ipll(kn)=ipll(kh)
            ipll(kh)=kn
          endif else begin
            ing=ipgrp(kn)
            ipllkh=ipll(kh)
            ipn=ighoc(ing)
            ighoc(ing)=0
            ipll(kh)=ipn
            fivetwentyfour: if (ipll(ipn) ne 0) then begin
              ipgrp(ipn)=ihg
              ipn=ipll(ipn)
              goto, fivetwentyfour
            endif
            ipgrp(ipn)=ihg
            ipll(ipn)=ipllkh
          endelse
          
         ;the above routines are used to add a star to a group.  It 
         ;first checks to see if the star is already in a group, and if so
         ;it merges groups together
 
        fivetwentyfive:
        endfor

   ; fivetwentysix:
    endfor

  fivethirty:
  endfor

fivefifty:
endfor

print,'clustering length =   ',step*d+mind
print,'nhctot =  ',nhctot
print,'# groups before cleaning =   ',ig

ng=0.0
for k=1L,ig do begin

if (ipll(ipll(ighoc(k))) ne 0) then begin
;three or more stars is a group
  
  ng=ng+1

endif
endfor
print,'# groups after cleaning =  ',ng

totalclust(0,d)=step*d+mind
totalclust(1,d)=ng
;stores clustering length and # of groups

if ng gt maxng then begin

  maxng=ng
  mghoc(*)=ighoc(*)
  mpll(*)=ipll(*)

endif
;this routine stores group data from the clustering length
;that had the most groups

endfor
;ends clustering length iteration

openw,two,outfile,/get_lun
printf,two,'Clustering Length(pc)   # of Clusters'
printf,two,totalclust
free_lun,two
;creates output file that prints clustering length and # groups

;The routine below creates an output file that prints the group
;data.  It does this by printing the starnumbers of the stars 
;in each group, then printing '0' after it prints all the stars
;in a group.  It then prints all the stars of the next group, then
;prints '0', then prints the stars of the next group...

openw,three,outfile2,/get_lun

for k=1L,n do begin

if (mpll(mpll(mghoc(k))) ne 0) then begin

q=mpll(mghoc(k))
printf,three,mghoc(k)
printf,three,q

while (q ne 0) do begin

q=mpll(q)
printf,three,q

endwhile
endif
endfor

free_lun,three

end

