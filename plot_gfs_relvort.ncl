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

;*******************************************************
; Define what variables, domains, and directories
;*******************************************************

varname = "gfs_500Z"

foldername = "feb2024"  ; event name

;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------

;*******************************************************
; Define what dates to plot
;*******************************************************

byyyy = 2024            ; Define intialization date to plot (yyyy mm dd hh)
bmm = 2
bdd = 10
bhh = 18

eyyyy = 2024    ; Define valid date to plot (yyyy mm dd hh)
emm = 2
edd = 12
ehh = 6

timeUnits = "hours since 1800-01-01 00:00:00"
bdate = cd_inv_calendar(byyyy,bmm,bdd,bhh,00,00,timeUnits,0)
edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

print(" ")
print("bdate: "+ut_string(bdate,""))
print("edate: "+ut_string(edate,""))
print(" ")

do date = bdate,edate,6       ; Create images from start date to end date (with 6 h increments)


; ******************************************************
; Load files
; ******************************************************
    print("Date:  "+ut_string(date,"")+" | Creating image")     ; Print date currently being plotted
        yyyy = ut_string(date,"%Y")                     ; Determine year of current date in yyyy form
        mm = ut_string(date,"%N")
        dd = ut_string(date,"%D")
        hh = ut_string(date,"%H")

print(" ")
print("yyyymmddhh: "+yyyy+mm+dd+hh)
name=varname+"_int"+yyyy+mm+dd+hh+"_F000"
print("name: "+name)

infile="/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/download_data/gfs."+yyyy+mm+dd+"/"+hh+"/atmos/gfs.t"+hh+"z.pgrb2.0p25.f000"
print("infile: "+infile)

    prod_gfs = addfile(infile+".grb2","r")

   slp=prod_gfs->HGT_P0_L100_GLL0({50000},:,:)
   slp=slp/10. ;convert from m to dam

  lev = (/50000/) ; Needs to be in Pa

  u = prod_gfs->UGRD_P0_L100_GLL0({lev},::-1,:)
  v = prod_gfs->VGRD_P0_L100_GLL0({lev},::-1,:)

  rel_vort = uv2vrF_Wrap(u,v)
  rel_vort = rel_vort*(10^5)

;   vortprod=prod_gfs->ABSV_P0_L100_GLL0({50000},:,:)
;   vortprod=vortprod*10^5

print("Successfully got data from files!")

;=============================================

folder = (/"conus"/)                   ;(/"EC"/)
;folder = (/"northamer","pacific","atlantic","europe","southpac","southamer","india","australia","africa","asia"/)   
enddomain = dimsizes(folder)

do x = 0,enddomain-1

domain = folder(x)

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

wks = gsn_open_wks(wks_type,dir_out+name)
;gsn_define_colormap(wks,"vort")
gsn_define_colormap(wks,"sunshine_9lev")
;**********************************************

res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"

res@cnFillOn = True                                              ; Turn on color fill
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLinesOn = False                               ; Relative Vorticity Shading Information
res@cnLevelSpacingF = 1
;res@cnLevels=ispan(16,50,4)
res@cnFillColors(0)=-1
res@cnLevels = (/6,8,10,12,16,20,24,28/)

;********************************************

res@lbLabelBarOn = True
res@lbAutoManage = False                   ; Label Bar Information
res@pmLabelBarOrthogonalPosF = 0.02  
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.61
res@lbLabelAutoStride = True
res@lbLabelFontHeightF = 0.011
res@lbBoxLinesOn  = True                   ; Outline the color bar 
res@lbTopMarginF = .3

; *********************************************

res@mpGeophysicalLineThicknessF = 3.0
res@mpNationalLineThicknessF = 3.0
res@mpUSStateLineThicknessF = 3.0
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
res@pmTickMarkDisplayMode = "Always"

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

if domain .eq. "conus" then
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

; *************************************************************

cnres = True                                            ; Geopotential height information

cnres@gsnFrame = False
cnres@gsnDraw = False

cnres@gsnLeftString = " "
cnres@gsnRightString = " "

cnres@cnInfoLabelOn = False
cnres@cnFillOn = False
cnres@cnLinesOn = True
cnres@cnLabelMasking = True
cnres@cnLineThicknessF = 4
cnres@cnLevelSelectionMode = "ManualLevels"
cnres@cnLevelSpacingF = 6
cnres@cnMinLevelValF = 450
cnres@cnMaxLevelValF = 606
cnres@cnLineLabelAngleF = 0.0
cnres@cnLineLabelInterval = 2
cnres@cnLineLabelDensityF = .90
;cnres@cnSmoothingOn = True
;cnres@cnSmoothingDistanceF = 0.009
cnres@cnLineLabelBackgroundColor = -1
cnres@cnLineLabelFontHeightF = 0.008
cnres@gsnAddCyclic = True

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
        res@gsnLeftString = "GFS Analysis | Init.: "+ut_string(date,"")+" | 500-hPa geo. height and relative vorticity"
	res@gsnLeftStringOrthogonalPosF = .010
	res@gsnLeftStringFontHeightF = .010
	
	;mres@gsnLeftStringFontColor = "black"
	;mres@gsnLeftString = "Initialized: "+ut_string(curdate,"")+" | Forecast hour: "+fhr_cur+" | Valid: "+ut_string(curdate,"")
	;mres@gsnLeftStringOrthogonalPosF = .010
	;mres@gsnLeftStringFontHeightF = .010


; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
cnres@cnLineDrawOrder ="Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks, rel_vort, res)          ; Plot filled contour map
contours = gsn_csm_contour(wks, slp, cnres)
plot = add_map_tickmarks(wks,plot,tmres)

;********************************************

overlay(plot,contours)


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
end do          ; date

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
