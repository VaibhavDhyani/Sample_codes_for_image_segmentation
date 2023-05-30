close all
% Combine both nucleus and mitochondria images for segmentation
I = Nucleus_MIP+Mito_MIP; 
[X,Y] = size(I); % Image dimensions
count = 1;
threshold =  0.4*max(max(I)); % Threshold
for x = 1:X
    for y = 1:Y
        if I(x,y)>threshold
            % Obtain features of each pixle: x, y, intensity of nucleus,
            % and intensity of mitochondria
            Feature_matrix(count,:) = [x,y,Nucleus_MIP(x,y),Mito_MIP(x,y)];
            count = count+1;
        end
    end
end
% Parameters of DBSCAN. These can be adjusted as per image type.
Search_radius = 3; 
Minimum_points = 25;
idx =  dbscan(Feature_matrix(:,1:2),Search_radius,Minimum_points);
outliers = find(idx<0); % Remove noise pixles
idx(outliers) = [];
Feature_matrix(outliers,:) = [];
[Fsize,~] = size(Feature_matrix);
for Cell = 1:max(idx)
  clear clusterlabels
  clusterlabels = find(idx==Cell);
  % Calculate centroid and total intensity of each cell
  Centroid(Cell,1) = mean(Feature_matrix(clusterlabels,1)); 
  Centroid(Cell,2) = mean(Feature_matrix(clusterlabels,2));
  Total_mitohchondrial_intensity(Cell) = sum(Feature_matrix(clusterlabels,4));
  Total_mitohchondrial_vol(Cell) = 0;
  XofCell = Feature_matrix(clusterlabels,1);YofCell = Feature_matrix(clusterlabels,2);
  for iz = 1:12
      Temp3D = Mito_image_3D(:,:,iz);
      Temp3D(Temp3D>0) = 1;
      for xi = 1:numel(XofCell)
          Total_mitohchondrial_vol(Cell) = Total_mitohchondrial_vol(Cell) + Temp3D(XofCell(xi),YofCell(xi)); 
      end
  end
  Total_mitohchondrial_vol(Cell)
end
subplot(221)
% Plot segmented cells
scatter(Feature_matrix(:,1),Feature_matrix(:,2),10,idx,'filled')
set(gca,'XTick',[],'YTick',[])
box on
subplot(222)
% Plot mitochondria intensity of cells as violin plot
violin(Total_mitohchondrial_intensity'); hold on;  
scatter(normrnd(1,0.05,[max(idx),1]),Total_mitohchondrial_intensity','filled')
legend off
ylabel('MitoView 488 intensity')
subplot(223)
% Plot mitochondria intensity of cells as violin plot
violin(Total_mitohchondrial_vol'); hold on;  
scatter(normrnd(1,0.05,[max(idx),1]),Total_mitohchondrial_vol','filled')
legend off
ylabel('MitoView 488 Vol')
subplot(224)
% Plot mitochondria intensity of cells as violin plot
scatter(Total_mitohchondrial_intensity,Total_mitohchondrial_vol,'filled')
box on
xlabel('MitoView Intensity')
ylabel('MitoView Volume')