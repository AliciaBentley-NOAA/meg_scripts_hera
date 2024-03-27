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

varname = "gfs_mslp"

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

byyyy = 2024		; Define intialization date to plot (yyyy mm dd hh)
bmm = 2
bdd = 10
bhh = 0   

eyyyy = 2024	; Define valid date to plot (yyyy mm dd hh)
emm = 2
edd = 16
ehh = 0

timeUnits = "hours since 1800-01-01 00:00:00"
bdate = cd_inv_calendar(byyyy,bmm,bdd,bhh,00,00,timeUnits,0)
edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

print(" ")
print("bdate: "+ut_string(bdate,""))
print("edate: "+ut_string(edate,""))
print(" ")

do date = bdate,edate,24       ; Create images from start date to end date (with 24 h increments)

; ******************************************************
; Load files
; ******************************************************
    print("Date:  "+ut_string(date,"")+" | Creating image") 	; Print date currently being plotted
	yyyy = ut_string(date,"%Y")    			; Determine year of current date in yyyy form
        mm = ut_string(date,"%N")
        dd = ut_string(date,"%D")
        hh = ut_string(date,"%H")

        ayyyy = ut_string(edate,"%Y")                     ; Determine year of current date in yyyy form
        amm = ut_string(edate,"%N")
        add = ut_string(edate,"%D")
        ahh = ut_string(edate,"%H")

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

  levs_wind  = (/25000/)

  mslp = prod_gfs->PRMSL_P0_L101_GLL0(::-1,:)
  mslp = mslp * .01

  u_all = prod_gfs->UGRD_P0_L100_GLL0({levs_wind},::-1,:)
  v_all = prod_gfs->VGRD_P0_L100_GLL0({levs_wind},::-1,:)

  if(dimsizes(levs_wind).eq.1) then
    u = u_all
    v = v_all
  else
    u = dim_avg_n_Wrap(u_all,0)
    v = dim_avg_n_Wrap(v_all,0)
  end if

  jet = u
  jet = ((u^2)+(v^2))^0.5

;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_out+name)
gsn_define_colormap(wks,"alicia")
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
res@cnLevels = (/30,40,50,60,70,80,90,100,110/)
res@cnFillColors = (/-1,13,12,11,31,32,33,43,25,24/)

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

res@gsnLeftString = "GFS | Init.: "+ut_string(date,"")+" | Fhr: "+fhr+" | Valid: "+ut_string(edate,"")+" | MSLP and 250-hPa wind speed"
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

res@mpGridAndLimbOn = False							; Grid lines and tick mark information
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


if domain .eq. "midwest" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 11
res@mpLambertParallel1F = 5
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 33
res@mpMaxLatF = 50
res@mpMinLonF = -109
res@mpMaxLonF = -81
res@tmXBValues := ispan(-180,179,20)
res@tmYLValues := ispan(0,80,20)
res@tmYRValues := ispan(0,80,20)
end if


if domain .eq. "gom" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 11
res@mpLambertParallel1F = 5
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 13.5
res@mpMaxLatF = 34.5
res@mpMinLonF = -99.5
res@mpMaxLonF = -72.5
res@tmXBValues := ispan(-180,179,5)
res@tmYLValues := ispan(0,80,5)
res@tmYRValues := ispan(0,80,5)
end if


; *************************************************************

mres = True

mres@gsnFrame = False
mres@gsnDraw = False

mres@gsnLeftString = " "
mres@gsnRightString = " "

mres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
mres@cnFillOn = False
mres@cnLineLabelsOn = True
mres@cnLinesOn = True
mres@cnLabelMasking = True
mres@cnLineThicknessF = 4                    ; Changes thickness of contours
mres@cnLevelSelectionMode = "ManualLevels"
mres@cnLevelSpacingF = 4
mres@cnMinLevelValF = 800
mres@cnMaxLevelValF = 1200
mres@cnLineLabelAngleF = 0.0
mres@cnLineLabelInterval = 2
mres@cnLineLabelDensityF = 1.4
;mres@cnSmoothingOn = True
;mres@cnSmoothingDistanceF = 0.009
mres@cnLineLabelBackgroundColor = -1
mres@cnLineLabelFontHeightF = 0.008
mres@gsnAddCyclic =  True

mres@cnLowLabelsOn=True
mres@cnLowLabelBackgroundColor=-1
mres@cnLowLabelFontColor="red"
mres@cnHighLabelFontHeightF=.019
mres@cnHighLabelFont = "helvetica-bold"
mres@cnLowLabelFont = "helvetica-bold"

; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
mres@cnLineDrawOrder ="Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks, jet, res)          ; Plot filled contour map
contours = gsn_csm_contour(wks, mslp, mres)

  setvalues contours
   "cnConpackParams":(/ "HLX:50","HLY:50"/)
  end setvalues

;********************************************

overlay(plot,contours)

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
