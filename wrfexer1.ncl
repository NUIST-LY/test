;;;;   load "/mnt/e/NUIST/2019/ncl/WRFexer/wrfexer1.ncl"


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions


begin


;dataadd = "/THL6/home/chenhs/duxg/wrf/wrf4.0/run/"
;dataadd = "/mnt/e/NUIST/2019/ncl/WRFexer/"
dataadd = "C:/Users/LY/Desktop/"
datatime = "2000-01-24_00_00"
a = addfile(dataadd + "wrfout_d01_" + datatime + "_00.nc", "r")
;a = addfile("C:/Users/LY/Desktop/wrfout_d01_2000-01-24_00_00_00.nc","r")

; What times and how many time steps are in the data set?
  ;times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ;ntimes = dimsizes(times)         ; number of times in the file
  ;;; 此处时间只有一个时次
  it = 0
; The specific pressure levels that we want the data interpolated to.
  pressure_levels = (/ 850., 500., 200./)   ; pressure levels to plot
  nlevels         = dimsizes(pressure_levels)     ; number of pressure levels

;;; http://www.ncl.ucar.edu/Document/Functions/WRF_arw/wrf_user_getvar.shtml
    tc = wrf_user_getvar(a,"tc",it)        ; Temperature in C
    u  = wrf_user_getvar(a,"ua",it)        ; u averaged to mass points
    v  = wrf_user_getvar(a,"va",it)        ; v averaged to mass points
    p  = wrf_user_getvar(a, "pressure",it) ; pressure is our vertical coordinate
 ;   z  = wrf_user_getvar(a, "z",it)        ; grid point height
 ;   rh = wrf_user_getvar(a,"rh",it)        ; relative humidity
 ;   printVarSummary(p)

wks = gsn_open_wks("png",dataadd + "uv&T@850@500@200")
res = True
res@gsnDraw  = False        ; don't draw the plots now
res@gsnFrame = False       ; or advance the frame
res@tmXBLabelFont   = 25        ;xy轴的字体
res@tmYLLabelFont   = 25 
res@tmXBLabelFontHeightF = 0.02
res@tmYLLabelFontHeightF = 0.02
res@NoHeaderFooter = True            ; Switch headers and footers off




;;; Overlay contours on a map
pnres = res ;; panel draw setting
pnres@PanelPlot = True     ; Indicate these plots are to be paneled.
;pnres@cnInfoLabelOn = False
;pnres@CommonTitle = True
;pnres@PlotTitle = ""
;pnres@Notitles = True 


plot = new(3,graphic)




 

do ipres = 0,nlevels-1
;;;;;; set vector ;;;;;;;
  vcres = res
  vcres@cnInfoLabelOn = False;关掉默认标签
  vcres@vcGlyphStyle            = "CurlyVector";矢量格式
  vcres@vcMinDistanceF          = 0.02;0.017 指定相邻箭头之间的最小距离，避免重叠
  vcres@vcVectorDrawOrder         = "PostDraw" ;什么时候画箭头
  ;下面是参考箭头的设置
  vcres@vcRefAnnoOn               = True
  vcres@vcRefLengthF            = 0.05;0.045
  vectormag = (/10.0,25.0,50.0/)
  vcres@vcRefMagnitudeF           = vectormag(ipres);20.0;;3.0 
  vcres@vcRefAnnoSide             = "Top"
  vcres@vcRefAnnoString2On        = False
  vcres@vcRefAnnoPerimOn          = False
  vcres@vcRefAnnoOrthogonalPosF   = -0.25 ;-0.10  ;调整风标上下位置
  vcres@vcRefAnnoParallelPosF     = 0.999
  vcres@vcRefAnnoFont = 25
  vcres@vcRefAnnoFontColor = "black"
;;;;设置等值线 ;;;;;
  cres = res
  cres@cnInfoLabelOn = False
  cres@cnFillOn = True                ; 颜色填充
  cres@cnLevels = False               ; 等值线关闭
  cres@cnSmoothingOn = True  ;使得等值线更加光滑
  cres@cnSmoothingDistanceF=0.0005 ;等值线光滑水平 越小越光滑
  cres@cnFillDrawOrder      = "Predraw"  ; 画等值线的顺序 draw contours first
  gsn_define_colormap(wks,"MPL_RdBu") 
  gsn_reverse_colormap(wks) 
  cres@lbLabelsOn = True ;;Turn off individual label bars
  cres@lbLabelAutoStride = True    ; Spacing of lbar labels.
  cres@lbLabelFontThicknessF = 0.015
  cres@lbLabelFont = 25
  ;cres@lbLabelStrings = ""
  cres@lbTitleOn = False


  mpres = res
  mpres@mpFillDrawOrder = "PostDraw"
  
  mpres@mpDataBaseVersion    = "MediumRes"    ;海岸线 
  mpres@mpOutlineOn = True

  ;mpres@mpFillOn = True
  ;mpres@mpLandFillColor = "white"
  mpres@mpGeophysicalLineColor = "black"
  mpres@mpGeophysicalLineThicknessF = 2.7 ;粗细
  ;mpres@mpLandFillColor = 0





 

    pressure = pressure_levels(ipres)
    tc_plane = wrf_user_intrp3d(tc,p,"h",pressure,0.,False)
    u_plane  = wrf_user_intrp3d( u,p,"h",pressure,0.,False)
    v_plane  = wrf_user_intrp3d( v,p,"h",pressure,0.,False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  contourpic = wrf_contour(a,wks,tc_plane,cres)
  vectorpic = wrf_vector(a, wks, u_plane, v_plane, vcres)
;;;;; overlay
  plot(ipres) = wrf_map_overlays(a, wks,(/contourpic,vectorpic/), pnres, mpres)
  ;delete(contourpic)
  ;delete(vectorpic)
  ;delete([/cres,mpres,vcres/])
end do;;; end ipres loop 

   ; Panel the WRF plots.
    pnlres = True
    ;pnlres@gsnFrame = False
    ;pnlres@gsnFrame = False
    ;pnlres@gsnMaximize = True
    pnlres@gsnPanelMainString = "UV&T   " + datatime
    pnlres@gsnPanelMainFont = 25
    pnlres@gsnPanelMainFontHeightF = 0.01
    ;pnlres@cnInfoLabelOn = False
    pnlres@lbLabelsOn = False
    ;pnlres@lbLabelFontHeightF = 0.02
    ;pnlres@lbLabelFont = 25
    

   ; pnlres@txString                   = t@description + "  (" + t@units + ")"
   ; pnlres@gsnPanelYWhiteSpacePercent = 13       ; Add white space b/w plots.
   ; pnlres@gsnPanelLabelBar           = True    ; Turn on common labelbar
   ; pnlres@lbLabelAutoStride          = True    ; Spacing of lbar labels.
   ; pnlres@lbBoxMinorExtentF          = 0.13

    gsn_panel(wks,(/plot/),(/3,1/),pnlres)


draw(plot)
frame(wks)











end