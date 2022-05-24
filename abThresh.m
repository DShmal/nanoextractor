function [zThresh] = abThresh(chan)
fig = uifigure('Name','Set Channel Threshold','Position',[10 1 1294 1024],'HandleVisibility', 'on');
ax = uiaxes(fig,'Position',[5 150 300 120]);
scrl = uislider(fig,'Position',[10 70 290 50],'ValueChangedFcn',@(fig,event) scroll());
scrl.Limits = [1 size(chan,3)];
sld = uislider(fig,'Position',[10 120 290 50],'ValueChangedFcn',@(fig,event) updateImg());
sld.Limits = [1 255];
[counts,binLocations] = imhist(chan(:,:,1));
stem(ax,binLocations,counts,'Marker','none');
ax.XLim = [1 255];
ax.YTickLabel =[];
ax.XTickLabel = [];
newthresh = sld.Value/255;
btn = uibutton(fig,'state','Text','Set','Position',[20, 5, 100, 22],'ValueChangedFcn', @(fig,event) SetBtn());
xtBtn = uibutton(fig,'push','Text','Done','Position',[140, 5, 100, 22],'ButtonPushedFcn', @(fig,event) ExitBtn());
% Create ValueChangedFcn callback
imaxes = uiaxes(fig,'Position',[270 -200 1024 1024]);
axes(imaxes);
cg=imshow(chan(:,:,1));
uiwait()
function updateImg()
newthresh = sld.Value/255;
zDepth = round(scrl.Value);
tSlice = im2bw(chan(:,:,zDepth),newthresh);
axes(imaxes);
cg = imshow(tSlice);
drawnow()
axes(ax);
[counts,binLocations] = imhist(chan(:,:,zDepth));
stem(ax,binLocations,counts,'Marker','none');
xl=xline(ax,sld.Value,'r',string(newthresh));
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'center';


end

function scroll()
zDepth = round(scrl.Value);
tSlice = im2bw(chan(:,:,zDepth),sld.Value/255);
axes(imaxes);
cg = imshow(tSlice);
drawnow
axes(ax);
[counts,binLocations] = imhist(chan(:,:,zDepth));
stem(ax,binLocations,counts,'Marker','none');
xl=xline(ax,sld.Value,'r',string(newthresh));
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'center';


end

function SetBtn()
zThresh = newthresh;
end

function ExitBtn()
zThresh = newthresh;
uiresume()
close all
end

end