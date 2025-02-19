; ===========================================
; Plotting GFS archive overnight to correct
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "~/ncl/lib/tTick.ncl"
load "~/ncl/lib/ut_string.ncl"
load "~/ncl/lib/latlon.ncl"
load "~/ncl/lib/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
; ===========================================

;system("setenv NCARG_COLORMAPS /home/Alicia.Bentley/colormaps")

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

period = 24
model = "gfs"
varname = "precip"
name = model+"_"+varname+"_int2024020900_val2024021112"

;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------

	timeUnits = "hours since 1800-01-01 00:00:00"
 
        iyyyy = 2024
        imm = 2
        idd = 9
        ihh = 0

	syyyy = 2024 
	smm = 2
	sdd = 10
	shh = 12

        eyyyy = 2024
        emm = 2
        edd = 11
        ehh = 12

        idate = cd_inv_calendar(iyyyy,imm,idd,ihh,00,00,timeUnits,0)
        sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
        edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

        print("idate:  "+ut_string(idate,""))
	print("sdate:  "+ut_string(sdate,""))
	print("edate: "+ut_string(edate,""))
    

;*****************************************************

diff = sdate - idate
print("diff: "+diff)

        ; Set date strings
        ymd = ut_string(idate,"%Y%N%D")
        hour = ut_string(idate,"%H")
        print("ymd+hour: "+ymd+hour)

start_fhr = diff
end_fhr = start_fhr+period

print("start_fhr: "+start_fhr)
print("end_fhr: "+end_fhr)

;------------------------------------------

	if start_fhr .ge. 100 then
        	fhr1 = start_fhr
	else if start_fhr .ge. 10 .and. start_fhr .lt. 100 then
        	fhr1 = "0"+start_fhr
	else if start_fhr .lt. 10 then
        	fhr1 = "00"+start_fhr
	end if
	end if
	end if
        print("fhr1: "+fhr1)


        if end_fhr .ge. 100 then
                fhr2 = end_fhr
        else if end_fhr .ge. 10 .and. end_fhr .lt. 100 then
                fhr2 = "0"+end_fhr
        else if end_fhr .lt. 10 then
                fhr2 = "00"+end_fhr
        end if
        end if
        end if
        print("fhr2: "+fhr2)
      
       filename1 = "/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/download_data/gfs."+ymd+"/"+hour+"/atmos/gfs.t"+hour+"z.pgrb2.0p25.f"+fhr1+".grib2"
       filename2 = "/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/download_data/gfs."+ymd+"/"+hour+"/atmos/gfs.t"+hour+"z.pgrb2.0p25.f"+fhr2+".grib2"
       if (isfilepresent(filename1)) then
          print("File1 found!")
       else
          print("File2 is missing...")
          system("pwd")
       end if

       if (isfilepresent(filename2)) then
          print("File2 found!")
       else
          print("File2 is missing...")
          system("pwd")
       end if

       a=addfile(filename1,"r")
       b=addfile(filename2,"r")


print("model: "+model)
  snowvara = "APCP_P8_L1_GLL0_acc"+start_fhr+"h"
  snowvarb = "APCP_P8_L1_GLL0_acc"+end_fhr+"h"
print("snowvara: "+snowvara)
print("snowvarb: "+snowvarb)

      orig_snod = a->$snowvara$(:,:)
      new_snod = b->$snowvarb$(:,:)
      orig_snod=orig_snod*.0393701     ; mm to inches
      new_snod=new_snod*.0393701     ; mm to inches
;      lat2d = a->gridlat_0
;      lon2d = a->gridlon_0
;      orig_snod@lat2d = lat2d
;      orig_snod@lon2d = lon2d
;      new_snod@lat2d = lat2d
;      new_snod@lon2d = lon2d
      snowdepth_change = new_snod
      snowdepth_change = new_snod - orig_snod
      printMinMax(snowdepth_change,True)

print("Successfully got data from files!")

;=============================================

folder = (/"conus"/)
;folder = (/"northamer","pacific","atlantic","europe","southpac","southamer","india","australia","africa","asia"/)   
enddomain = dimsizes(folder)

do x = 0,enddomain-1

domain = folder(x)

print(" ")
print("Plotting maps for: "+domain)	      	

dir_plot = "./images/"+domain+"/"+varname+"/"         
dir_out = dir_plot
system("mkdir -p "+dir_out)

;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_plot+name)

gsn_define_colormap(wks,"precip")
;**********************************************

res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"

res@cnFillOn = True                                      ; Turn on color fill
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLinesOn = False                               ; Turn off contour lines
;res@cnLevelSpacingF = 1                            ; Shading interval
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/.01,.10,.25,.50,.75,1.0,1.25,1.5,1.75,2.0,2.5,3.0,4.0,5.0,6.0,7.0,8.0,9.0/)
;res@cnLevels = (/.25,2.5,5.0,10.0,15.0,20.0,30.0,40.0,50.0,60.0,70.0,80.0,100.0,120.0,140.0,160.0,180.0,200.0/)
res@cnFillColors = (/-1,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24/)

;********************************************

res@lbAutoManage = False                                                        ; Color bar information
res@pmLabelBarOrthogonalPosF = -.02
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.73
res@lbLabelAutoStride = True
res@lbLabelFontHeightF = 0.0124
res@lbBoxLinesOn  = True
res@lbTopMarginF = .3

; *********************************************

res@mpGeophysicalLineThicknessF = 4.0
res@mpNationalLineThicknessF = 4.0
res@mpUSStateLineThicknessF = 4.0
res@mpOutlineSpecifiers = (/"United States"/)+" : States"

res@mpGeophysicalLineColor = "grey29"
res@mpNationalLineColor = "grey29"
res@mpUSStateLineColor = "grey29"

; *********************************************

res@mpGridAndLimbOn = True
res@mpGridLineDashPattern = 5
res@mpGridLatSpacingF = 10.
res@mpGridLonSpacingF = 10.
res@mpGridLineThicknessF = 2
res@mpGridLineColor = "grey40"
;res@pmTickMarkDisplayMode = "Always"

tmres = True
tmres@tmXBLabelFontHeightF = .013
tmres@tmYLLabelFontHeightF = .013
tmres@tmYLLabelFontHeightF = .013

tmres@tmXBMajorLengthF = .01
tmres@tmXBMinorLengthF = .006

tmres@tmYRMinorValues = (/-75,-70,-65,-55,-50,-45,-35,-30,-25,-15,-10,-5,5,10,15,25,30,35,45,50,55,65/)
tmres@tmYLMinorValues = (/-75,-70,-65,-55,-50,-45,-35,-30,-25,-15,-10,-5,5,10,15,25,30,35,45,50,55,65/);tmres@tmXBMinorValues = (/-175,-170,-165,-160,-155,-150,-145,-135,-130,-125,-120,-115,-110,-105,-95,-90,-85,-80,-75,-70,-65,-55,-50,-45,-40,-35,-30,-25,-15,-10,-5,0,5,10,15,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,145,150,155,160,165,170,175/)
tmres@tmXBMinorValues = ispan(-180,179,5)
; *************************************************************


if domain .eq. "northamer"
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 8.
res@mpMaxLatF = 72.
res@mpMinLonF = -151.
res@mpMaxLonF = -49.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,20)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,20)
tmres@tmYRValues = ispan(0,80,20)
end if

if domain .eq. "conus2" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 25
res@mpLambertMeridianF = -95
res@mpLimitMode = "LatLon"
res@mpMinLatF = 19.
res@mpMaxLatF = 57.
res@mpMinLonF = -123.25
res@mpMaxLonF = -67.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

if domain .eq. "other" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 25
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 23.
res@mpMaxLatF = 52.
res@mpMinLonF = -122.
res@mpMaxLonF = -72.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

if domain .eq. "zoom" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 25
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 25.
res@mpMaxLatF = 50.
res@mpMinLonF = -108.
res@mpMaxLonF = -72.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

if domain .eq. "WI" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 30
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 41.
res@mpMaxLatF = 48.
res@mpMinLonF = -96.5
res@mpMaxLonF = -87.0
delete(tmres@tmXBValues)
tmres@tmYLOn = False
tmres@tmYROn = False
tmres@tmXBOn = False
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if


if domain .eq. "EC" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 35
res@mpLambertParallel1F = 30
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 35.
res@mpMaxLatF = 47.
res@mpMinLonF = -85.
res@mpMaxLonF = -69.
delete(tmres@tmXBValues)
tmres@tmYLOn = False
tmres@tmYROn = False
tmres@tmXBOn = False
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if

if domain .eq. "conus" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 11
res@mpLambertParallel1F = 5
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 20
res@mpMaxLatF = 52
res@mpMinLonF = -125
res@mpMaxLonF = -67
res@tmXBValues := ispan(-180,179,20)
res@tmYLValues := ispan(0,80,20)
res@tmYRValues := ispan(0,80,20)
end if

;**********************************************

  curdate = edate	
  curdate@units = "hours since 1800-01-01 00:00:00"
  fhr_cur = "0"

	res@tiMainString = " "
	res@tiMainJust = "CenterCenter"
	res@tiMainPosition = "Center" 
	res@tiMainOffsetYF = .02
	res@tiXAxisFontHeightF = .015
	
	res@gsnRightString = " "
	
	res@gsnLeftStringFontColor = "black"
        res@gsnLeftString = "GFS | Init.: "+ut_string(idate,"")+" | Fhrs: "+start_fhr+"-"+end_fhr+" | Valid: "+ut_string(edate,"")+" | 24-h precipitation (in.)"
	;res@gsnLeftString = "("+model+") "+period+"-h SNOD Init: "+ut_string(idate,"")+" | Fhrs: "+start_fhr+"-"+end_fhr+" | Val: "+ut_string(edate,"")
	res@gsnLeftStringOrthogonalPosF = .010
        ;res@gsnLeftStringFontHeightF = .010
        res@gsnLeftStringFontHeightF = .008
        res@gsnRightStringFontHeightF = .012
	


; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
;thres@cnLineDrawOrder ="Draw"
;th2res@cnLineDrawOrder ="Draw"
;mres@cnLineDrawOrder ="Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks,snowdepth_change, res)          ; Plot filled contour map
;plot = add_map_tickmarks(wks,plot,tmres)

;==============================================

;overlay(plot,other)
;overlay(plot,other2)
;overlay(plot,contours)
;overlay(plot,barbs)

;********************************************

draw(plot)
frame(wks)

;********************************************

;system("pngquant "+dir_plot+name+".png")
;system("'mv' "+dir_plot+name+"-fs8.png "+dir_plot+name+".png") 
system("convert "+dir_plot+name+".png -trim +repage "+dir_out+name+".png")

print("Image created in: "+dir_out)

;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************

end do     	; end domain

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
