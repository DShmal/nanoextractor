%% Nanoparticle batch analysis
% uses ci_loadLif (c) Ron Hoebe, Cellular Imaging - Core Facility, AMC - UvA - Amsterdam - The Netherlands
%
% the aim here is to simultaneously do a fluorescence colocalization analysis
% (like JACoP in ImageJ) and calculate number and dimensions of fluorescent
% objects in the P3HT emission channel (as would be done using
% ImageJ's 3D object counter plugin), keeping the same threshold across
% both analyses in order to perform them in batch and automatically.
%
%
%%


clc;
clearvars;
%ui to open raw .lif file
[fname, pth] = uigetfile('*.lif','Select LIF');
fullfile = [pth,fname];
[~,imgList] = ci_loadLif(fullfile,0,1);
 list = struct2table(imgList,'AsArray',true);
%show list of available images in file
 figure('InnerPosition',[7,204,143,271],'OuterPosition',[-1,196,159,364])
 uitable('Data',list.Name,'InnerPosition',[17,15,113,245])
%serve dialog to input desired image number to analyze
 imIdx = inputdlg('Load Sequence Number?','Choose Image',1)
[img,imgList] = ci_loadLif(fullfile,0,str2double(imIdx{1}));

%create max-intensity projections of nuclei (ch. 1), antibody (ch. 2), 
%and P3HT channels(ch. 3).
curCh3 = img.Image{3};
cCmax3 = max(curCh3,[],3);
curCh2 = img.Image{2};
cCmax2 = max(curCh2,[],3);
curCh1 = img.Image{1};
cCmax1 = max(curCh1,[],3);

%serve dialog to draw bounds of VOI around INL (for INL NP density
%measurement)
figure()
[xrefout,yrefout,INLmask,xi2,yi2] = roipoly(cCmax1);

%call thresholding dialog function for P3HT and Antibody Channels
[zThresh] = abThresh(curCh2);
[npThresh] = abThresh(curCh3);
%nuclei channel is arbitrarily hard-thresholded simply for visualization in
% max intensity projection, as no quantitative analysis is done on them
cCT1 = im2bw(cCmax1,0.24);
%retrieve pixel scale from metadata
dims=struct2table(imgList(1).Dimensions); 
pixelsize = str2double(dims.Length(1))/str2double(dims.NumberOfElements(1));
pixelarea = pixelsize^2;
pixelarea = pixelarea*1000000000000; %convert scale to pixel area
zStep = str2double(dims.Length(3))/(str2double(dims.NumberOfElements(3))-1);
zStep = abs(zStep*1000000); % z-step in um

%main loop to extract colocalization in VOI on each z-slice (a logical AND between Ab and P3HT
%Channels)
for hh = 1:size(curCh3,3)
    zSlice = im2bw(curCh3(:,:,hh),npThresh);
    abSlice = im2bw(curCh2(:,:,hh),zThresh);
    abSlice = abSlice & INLmask;
    unfilt(:,:,hh) = zSlice;
    unfOver(:,:,hh)= zSlice & abSlice;
    unfMand(hh)=sum(unfOver(:));
    fAb(:,:,hh) = abSlice;
end
%colocalization coefficients (Manders) on ROI
fAbf = fAb & INLmask;
unfiltF = unfilt & INLmask;
uM1 = sum(unfMand)/sum(unfiltF,'all');
uM2 = sum(unfMand)/sum(fAbf,'all');

%compile and extract P3HT Channel 3d object data using Image Processing
%toolbox. bwconncomp will classify all contiguous "true" pixels as single object,
%and regionprops will extract relevant quantitative data from these objects
unfNps = bwconncomp(unfilt);
unfRP = regionprops(unfNps);
pixelUM=pixelsize*1000000;
unfCtr = cat(1,unfRP.Centroid);
unfCtr(:,3) = [unfCtr(:,3)]*zStep;
unfAreas = [unfRP.Area];
%retrieve bounding boxes of 3d objects to extract diameters and convert to
%um
unfBoxes = cat(1,unfRP.BoundingBox);  
unfOvRs(:,1)=unfBoxes(:,4)/2;
unfOvRs(:,2)=unfBoxes(:,5)/2;
unfOvRs(:,3)=unfBoxes(:,6)/2;
unfOvRs(:,1) = unfOvRs(:,1)*pixelUM;
unfOvRs(:,2) = unfOvRs(:,2)*pixelUM;
unfOvRs(:,3) = unfOvRs(:,3)*abs(zStep);
unfOvDs = unfOvRs.*2;
%correct for single-z-step overestimation of object z-dimension
unfOvDs(:,3) = unfOvDs(:,3)-(zStep-pixelUM);
avgDs = mean(unfOvDs,2);
maxDs = max(unfOvDs,[],2);
minDs = min(unfOvDs,[],2);
%assume object is an ovoid inscribed into bounding box, calculate volume
unfVols= (4/3).*pi.*unfOvRs(:,1).*unfOvRs(:,2).*unfOvRs(:,3);
unfNPinINL= inpolygon(unfCtr(:,1),unfCtr(:,2),xi2,yi2);
%classify whether objects are inside or outside the INL VOI (used for injection
%quality control), count and calculate average diameters.
unfVolsINL = unfVols(unfNPinINL ==1);
unfVolsEX = unfVols(unfNPinINL ==0);
unfINLNPs = unfCtr((unfNPinINL ==1),:);
unfINLavgDs = avgDs(unfNPinINL == 1);
unfINLNPs(:,4)= unfVolsINL;
unfExtraINL = unfCtr((unfNPinINL==0),:);
unfExtraINL(:,4)= unfVolsEX;

%find points of colocalization between P3HT and the Ab, locate centroids
%and count them.
unfContactPts = regionprops(unfOver,'Centroid');
unfContactPts = cat(1,unfContactPts.Centroid);
if height(unfContactPts) ~= 0
unfContactPts(:,3) = unfContactPts(:,3).*zStep;
end 

%output data save paths, 3d isosurface patch visualization of P3HT and
%Contacts
[~,nm] = fileparts(fname);
savePath = (pwd+"\Output Data\"+nm+"\");
saveName = (savePath+imgList(str2double(imIdx{1})).Name+".xlsx");
mkdir(savePath)
figure()
[f,v] = isosurface(unfilt);
p2=patch('Faces',f,'Vertices',v,'FaceColor','red','EdgeColor','none')
isonormals(unfilt,p2);
camlight
camlight(-80,-10)
lighting gouraud
hold on
if height(unfContactPts) ~= 0
scatter3(unfContactPts(:,1),unfContactPts(:,2),unfContactPts(:,3),30,'sm');
end
view(-1.152754253308128e+02,67.701953834720655);
ylim([0 1024]);
xlim([0 1024]);
tickIdx = 0:128:1024;
xticks([tickIdx]);
yticks([tickIdx]);
tickscale = 0:pixelsize*1000000:pixelsize*1024000000;
surface(zeros(1024,1024),cCmax1,'FaceColor','texturemap','EdgeColor','none','CDataMapping','direct')
colormap(copper)
set(gca,'color',[0.2 0.2 0.2])
set(gca,'GridColor',[0.30,0.75,0.93])
set(gca,'XTickLabel',{tickscale(tickIdx+1)})
set(gca,'YTickLabel',{tickscale(tickIdx+1)})
savefig((savePath+imgList(str2double(imIdx{1})).Name+".fig"));


%bin edges for histogram graphing
edgesUpl = 0:0.1:1;

%histogram counts and relative frequencies for volume and average diameter
countsUI = histc(unfVolsINL,edgesUpl);
countsUE = histc(unfVolsEX,edgesUpl);
countsUT = histc(unfVols,edgesUpl);
relFreqsUI = countsUI/sum(countsUI);
relFreqsUE = countsUE/sum(countsUE);
relFreqsUT = countsUT/sum(countsUT);

cts = histcounts(unfINLavgDs,[0:0.5:ceil(max(avgDs))]);
totCts = histcounts(avgDs,[0:0.5:ceil(max(avgDs))]);

%calcuate area and volume of INL VOI
INLarea = polyarea(xi2,yi2)*pixelarea;
INLvol = INLarea*(size(curCh1,3)*zStep);

%write output data to excel file
results = table([0:0.5:ceil(max(avgDs))]',[cts,NaN]',[(cts./sum(cts))*100,NaN]',[totCts,NaN]',[(totCts./sum(totCts))*100,NaN]');
results.Properties.VariableNames = {'avgD','INLCounts','INL%','totCounts','tot%'};
resultsUM = table(uM2,height(unfContactPts),INLvol,height(unfINLNPs)/INLvol,(sum(avgDs > 10)),(sum(avgDs > 10))/height(avgDs));
resultsUM.Properties.VariableNames = {'NP/Ab uM2','uContactPoints','INLVolume','uINLDensity','>10μm Count','>10μm %'};
writetable(results,saveName,'WriteVariableNames',true);  
writetable(resultsUM,saveName,'WriteMode','Append','WriteVariableNames',true);
