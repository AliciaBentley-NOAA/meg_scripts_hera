; ===========================================
; Plots irrotational wind
; Created by: Alicia M. Bentley
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "~/ncl/lib/shea_util.ncl"
; ===========================================

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

;*******************************************************
; Define what variables, domains, and directories
;*******************************************************

varname = "gfs_mix_v3"

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
bdd = 9
bhh = 0  

eyyyy = 2024	; Define valid date to plot (yyyy mm dd hh)
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

do date = bdate,edate,12       ; Create images from start date to end date (with 24 h increments)

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

    a = addfile(infile+".grb2","r")

  pwat = a->PWAT_P0_L200_GLL0(::-1,:)

  lev_wind  = (/25000/)
  u_all = a->UGRD_P0_L100_GLL0({lev_wind},::-1,:)
  v_all = a->VGRD_P0_L100_GLL0({lev_wind},::-1,:)
  if(dimsizes(lev_wind).eq.1) then
    u = u_all
    v = v_all
  else
    u = dim_avg_n_Wrap(u_all,0)
    v = dim_avg_n_Wrap(v_all,0)
  end if

  wind = u
  wind = ((u^2)+(v^2))^0.5


   slp=a->HGT_P0_L100_GLL0({50000},:,:)
   slp=slp/10. ;convert from m to dam

  lev_omega  = (/60000,50000,40000/)
  w_all = a->VVEL_P0_L100_GLL0({lev_omega},::-1,:)
  w = dim_avg_n_Wrap(w_all,0)
  w = w*(.01)
;  copy_VarCoords(u_all,w)

lev_irro  = (/30000,25000,20000/)
  u_irro = a->UGRD_P0_L100_GLL0({lev_irro},::-1,:)
  v_irro = a->VGRD_P0_L100_GLL0({lev_irro},::-1,:)
  if(dimsizes(lev_irro).eq.1) then
    ui = u_irro
    vi = v_irro
  else
    ui = dim_avg_n_Wrap(u_irro,0)
    vi = dim_avg_n_Wrap(v_irro,0)
  end if
  div = uv2dvF_Wrap(ui,vi)
  irro = dv2uvF_Wrap(div)

;-----------------------------------------------

;  lev_pv  = (/20000,25000,30000/)
;  upv = a->UGRD_P0_L100_GLL0({lev_pv},::-1,:)
;  vpv = a->VGRD_P0_L100_GLL0({lev_pv},::-1,:)
;  tpv = a->TMP_P0_L100_GLL0({lev_pv},::-1,:)

;  lev_pv@units = "Pa"
;  pv_all = PotVortIsobaric(lev_pv,upv,vpv,tpv,tpv&lat_0,1,0)
;  pv = dim_avg_n_Wrap(pv_all,0)
;  pv = pv*(10^6)
;  copy_VarCoords(u,pv)
  
;  do d=0,6
;    pv=smth9(pv,.5,.25,True)
;  end do

  print("Successfully got data from files!")


;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_out+name)
gsn_define_colormap(wks,"alicia_pwat")
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
res@cnLevelSelectionMode = "ManualLevels"
res@cnLinesOn = False                               ; Turn off contour lines
res@cnLevelSpacingF = 1
res@cnLevelSpacingF = 5                             ; Shading interval
res@cnMinLevelValF = 20
res@cnMaxLevelValF = 70                          ; Shading interval
res@cnFillColors = (/-1,116,103,84,75,129,139,144,149,157,185,192/)

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

res@gsnLeftString = "GFS | Init.: "+ut_string(date,"")+" | Fhr: "+fhr+" | Valid: "+ut_string(edate,"")+" | 300-200-hPa Irro. Wind; 600-400-hPa w; 500Z; PW"
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
res@mpGridLineThicknessF = 2
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

; ************************************************************


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


; *************************************************************

jres = True

jres@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
jres@gsnDraw = False

jres@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
jres@mpDataSetName = "Earth..4"
jres@mpOutlineBoundarySets = "National"

jres@cnFillOn = True                                              ; Turn on color fill
jres@cnFillMode = "AreaFill"
jres@cnRasterSmoothingOn = True
jres@cnLevelSelectionMode = "ExplicitLevels"
jres@cnLinesOn = False                               ; Turn off contour lines
jres@cnLevelSpacingF = 1                            ; Shading interval
;jres@cnLevels = (/50,60,70,80,90,100/)
;jres@cnLevels = (/40,50,60,70,80,90/)
jres@cnLevels = (/30,40,50,60,70,80,90,100,110/)
jres@cnFillColors = (/-1,213,212,211,231,232,233,243,225,224/)
jres@lbLabelBarOn = True
jres@lbAutoManage = False
jres@cnLineLabelsOn = False
jres@cnInfoLabelOn = False 
jres@gsnAddCyclic =  True

; *************************************************************

pvres = True

pvres@gsnFrame = False                                        
pvres@gsnDraw = False

pvres@gsnLeftString = " "
pvres@gsnRightString = " "

pvres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
pvres@cnFillOn = False
pvres@cnLineLabelsOn = True
pvres@cnLinesOn = True
pvres@cnLabelMasking = True
pvres@cnLineThicknessF = 3.5                    ; Changes thickness of contours
pvres@cnLevelSelectionMode = "ManualLevels"
pvres@cnLevelSpacingF = 1
pvres@cnMinLevelValF = 2
pvres@cnMaxLevelValF = 30 
if domain .eq. "southamer" then
	pvres@cnMinLevelValF = -30
	pvres@cnMaxLevelValF = -1 
end if
pvres@cnLineLabelAngleF = 0.0
pvres@cnLineLabelInterval = 2
pvres@cnLineLabelDensityF = .77
pvres@cnLineLabelBackgroundColor = -1
pvres@cnLineLabelFontHeightF = 0.008
pvres@cnLineLabelFontColor = "blue"   ;grey15
pvres@cnLineColor = "blue"
pvres@gsnAddCyclic =  True

pvres@gsnLeftString = " "
pvres@gsnRightString = " "

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
omres@cnLineColor = "red2"   ;red2
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

    vres = True

    vres@gsnFrame = False                                        
    vres@gsnDraw = False
    vres@gsnAddCyclic =  True
    vres@gsnLeftString = " "
    vres@gsnRightString = " "
    
    vres@vcGlyphStyle = "FillArrow"
    vres@vcWindBarbColor = "black"
    vres@vcLineArrowColor = "black"
    vres@vcFillArrowEdgeColor = "black"
    vres@vcLineArrowThicknessF = 7
    vres@vcWindBarbCalmCircleSizeF = 0
    vres@vcWindBarbLineThicknessF = 7.5
    vres@vcMinDistanceF = 0.023
;    vres@vcMinDistanceF = 0.019
    vres@vcMinMagnitudeF = 3.0

    if domain .eq. "conus" then
    vres@vcRefAnnoOn = True 
    vres@vcRefAnnoString1 = "$VMG$ m s~S~~F15~-~F21~1"
;    vres@vcRefLengthF = 0.028
    vres@vcRefLengthF = 0.035
    vres@vcRefMagnitudeF = 10.0
    vres@vcRefAnnoSide = "Top"
    vres@vcRefAnnoOrthogonalPosF = -1.037
    vres@vcRefAnnoParallelPosF = .999
    vres@vcRefAnnoString2On = False
    end if

; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
jres@cnFillDrawOrder = "PreDraw"
pvres@cnLineDrawOrder ="Draw"
;pv2res@cnLineDrawOrder ="Draw"
omres@cnLineDrawOrder ="Draw" 
vres@vcVectorDrawOrder = "Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks, pwat, res)          ; Plot filled contour map
;jet = gsn_csm_contour(wks, wind, jres)
contours = gsn_csm_contour(wks, slp, cnres)
;contours = gsn_csm_contour(wks, pv({0:90},:), pvres)
;contours2 = gsn_csm_contour(wks, pv({-90:0},:), pv2res)
other = gsn_csm_contour(wks, w, omres)
vect = gsn_csm_vector(wks, irro(0,:,:), irro(1,:,:), vres)
;plot = add_map_tickmarks(wks,plot,tmres)

  setvalues contours
   "cnConpackParams":(/ "HLX:50","HLY:50"/)
  end setvalues

;********************************************

;overlay(plot,jet)
overlay(plot,contours)
;overlay(plot,contours2)
overlay(plot,other)
overlay(plot,vect)

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
