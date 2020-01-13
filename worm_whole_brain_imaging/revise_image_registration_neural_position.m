function adjust_centers=revise_image_registration_neural_position(C1_new,C2)
%% 1. form the distance matrix of (C1_new,C2)
numRow = size(C1_new,1);
numCol = size(C2,1);

disMatrix = zeros(numRow,numCol);
matching = zeros(numRow,1); % 1 denotes matching, 0 denotes no matching
for i=1:numRow
for j=1:numCol
disMatrix(i,j)=norm(C1_new(i,:)-C2(j,:));
end
end

for i=1:numRow
minNum = min(disMatrix(i,:));
colIndex = find(disMatrix(i,:)==minNum);
matching(i)=colIndex;
end
adjust_centers = C2(matching,:);

end