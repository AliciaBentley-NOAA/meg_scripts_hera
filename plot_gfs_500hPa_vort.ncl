; ===========================================
; Plots 500-hPa geopotential height
; Created by: Alicia M. Bentley
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
; ===========================================

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

;*******************************************************
; Define what variables, domains, and directories
;*******************************************************

varname = "gfs_relvort_v3"

foldername = "feb2024"  ; event name

folder = (/"conus"/)	; domain(s) to plot 
enddomain = dimsizes(folder)

do x = 0,enddomain-1       ; loop through all the domains you selected (only 1 domain if 1 domain selected)

domain = folder(x)

img_loc = "/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/"+foldername+"/images"   ; Define directory where images will ultimately be located (and create it)
;system("mkdir "+img_loc)
;system("mkdir "+img_loc+"/"+domain)
system("mkdir -p "+img_loc+"/"+domain+"/"+varname)
dir_out = img_loc+"/"+domain+"/"+varname+"/"

print(" ")
print("Plotting '"+varname+"' over '"+domain+"' for '"+foldername+"'")  ; Print what you are plotting
print("Images finally located: "+dir_out)

;*******************************************************
; Define what dates to plot
;*******************************************************

byyyy = 2024            ; Define intialization date to plot (yyyy mm dd hh)
bmm = 2
bdd = 10
bhh = 0

eyyyy = 2024    ; Define valid date to plot (yyyy mm dd hh)
emm = 2
edd = 12
ehh = 0

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
    print("Date:  "+ut_string(date,"")+" | Creating image") 	; Print date currently being plotted
	yyyy = ut_string(date,"%Y")    			; Determine year of current date in yyyy form
        mm = ut_string(date,"%N")
        dd = ut_string(date,"%D")
        hh = ut_string(date,"%H")

	fhr = edate-date

                 if (fhr.lt.10) then
                      filefhr := "00"+fhr
                 else if ((fhr.lt.100).and.(fhr.gt.10)) then
                      filefhr := "0"+fhr
                 else if (fhr.gt.100) then
                      filefhr := fhr
                 end if
                 end if
                 end if

print("filefhr: "+filefhr)
print("yyyymmddhh: "+yyyy+mm+dd+hh)
name=varname+"_int"+yyyy+mm+dd+hh+"_F"+filefhr
print("name: "+name)

infile="/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/download_data/gfs."+yyyy+mm+dd+"/"+hh+"/atmos/gfs.t"+hh+"z.pgrb2.0p25.f"+filefhr
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

  w = prod_gfs->VVEL_P0_L100_GLL0({lev},::-1,:)
  w = w*(.01)
  copy_VarCoords(u,w)

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
;res@cnFillColors(0)=-1
res@cnLevels = (/6,8,10,12,16,20,24,28/)
res@cnFillColors = (/-1,4,5,6,7,8,9,10,11/)

;**********************************************

res@lbAutoManage = False							; Color bar information
res@pmLabelBarOrthogonalPosF = -.02  
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.73
res@lbLabelAutoStride = True
res@lbLabelFontHeightF = 0.0124
res@lbBoxLinesOn  = True                        
res@lbTopMarginF = .3

;**********************************************

res@tiMainString = " "								; Image labels
res@tiMainJust = "CenterCenter"
res@tiMainPosition = "Center" 
res@tiMainOffsetYF = .02
res@tiXAxisFontHeightF = .015

res@gsnLeftString = "GFS | Init.: "+ut_string(date,"")+" | Fhr: "+fhr+" | Valid: "+ut_string(edate,"")+" | 500-hPa geo. height, relative vorticity, and ascent"
res@gsnLeftStringOrthogonalPosF = .012
res@gsnLeftStringFontHeightF = .008
res@gsnRightString = " "
res@gsnRightStringOrthogonalPosF = .0075
res@gsnRightStringFontHeightF = .012

; *********************************************

res@mpGeophysicalLineThicknessF = 2.0				; Map details
res@mpNationalLineThicknessF = 2.0
res@mpUSStateLineThicknessF = 2.0
res@mpOutlineSpecifiers = (/"United States"/)+" : States"

res@mpGeophysicalLineColor = "grey29"
res@mpNationalLineColor = "grey29"
res@mpUSStateLineColor = "grey29"

; *********************************************

res@mpGridAndLimbOn = True							; Grid lines and tick mark information
res@mpGridLineDashPattern = 5
res@mpGridLatSpacingF = 20.
res@mpGridLonSpacingF = 20.
res@mpGridLineThicknessF = 3
res@mpGridLineColor = "grey12"

; *************************************************************

if domain .eq. "eastcoast_zoom"                                      ; Define domains
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -75
res@mpLimitMode = "LatLon"
res@mpMinLatF = 19
res@mpMaxLatF = 54
res@mpMinLonF = -98
res@mpMaxLonF = -42
end if


if domain .eq. "westcoast_zoom"                                      ; Define domains
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -130
res@mpLimitMode = "LatLon"
res@mpMinLatF = 22
res@mpMaxLatF = 60
res@mpMinLonF = -161
res@mpMaxLonF = -99
end if


if domain .eq. "westcoast"                                      ; Define domains
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -130
res@mpLimitMode = "LatLon"
res@mpMinLatF = 8
res@mpMaxLatF = 69
res@mpMinLonF = -179
res@mpMaxLonF = -81
end if


if domain .eq. "northamer"					; Define domains	
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 8
res@mpMaxLatF = 69
res@mpMinLonF = -151
res@mpMaxLonF = -49
res@tmXBValues := ispan(-180,179,40)
res@tmYLValues := ispan(0,80,20)
res@tmYRValues := ispan(0,80,20)
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

; *************************************************************

cnres = True						; Geopotential height information

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

; *************************************************************

omres = True

omres@gsnFrame = False                                        
omres@gsnDraw = False

omres@gsnLeftString = " "
omres@gsnRightString = " "
omres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
omres@cnFillOn = False
omres@cnLinesOn = True
omres@cnLabelMasking = True
omres@cnLineLabelsOn = False
omres@cnLineThicknessF = 4
omres@cnLineColor = "blue"
omres@cnLevelSelectionMode = "ManualLevels"
omres@cnLevelSpacingF = 0.005
omres@cnMaxLevelValF = -0.005 
omres@cnLineLabelAngleF = 0.0
omres@cnLineLabelInterval = 1
omres@cnLineLabelDensityF = .77
omres@cnLineLabelBackgroundColor = -1
omres@cnLineLabelFontHeightF = 0.018
omres@gsnAddCyclic =  True


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
other = gsn_csm_contour(wks, w, omres)

;********************************************

overlay(plot,contours)
overlay(plot,other)

;********************************************

draw(plot)	; Draw final image
frame(wks)

;********************************************

system("convert "+dir_out+name+".png -trim +repage "+dir_out+name+".gif")
system("'rm' "+dir_out+name+".png")

end do     ; end date loop
print(" ")
end do     ; end domain loop

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
