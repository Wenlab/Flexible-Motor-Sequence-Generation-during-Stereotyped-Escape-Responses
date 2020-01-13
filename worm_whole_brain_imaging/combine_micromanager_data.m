function img_stack=combine_micromanager_data(img_stack1,img_stack2)

N1=length(img_stack1);
N2=length(img_stack2);
N=N1+N2;
img_stack=cell(N,1);

for j=1:N1
    img_stack{j,1}=img_stack1{j,1};
end

for j=1:N2
    img_stack{j+N1,1}=img_stack2{j,1};
end

end
    