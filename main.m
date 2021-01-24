clear;
states = [0 1 0 0 0]; % 0����δ���1��������2�����Ѽ�����״̬�����������װ�װ�Ϊ��һ����˳ʱ��˳����б�š�
f = 30;
t_max = 15; % ��λ��
k = 0.5; % ����ϵ��


%% ͼ���ʼ��
global activatedArmorSRC;
global unactivatedArmorSRC;
global targetArmorSRC;
global baseAngles;

Rsrc = imread("./img/R.png");
unactivatedArmorSRC = imread("./img/unactivated.png");
activatedArmorSRC = imread("./img/activated.png");
targetArmorSRC = imread("./img/target.png");
baseAngles = [0, 2*pi/5, 4*pi/5, 6*pi/5, 8*pi/5];

% imshow(insertMonoArmor(zeros(1000,1000,3,'uint8'),targetArmorSRC,0,0.5))
bg = zeros(1024,1280,3,'uint8');
Rheight = size(Rsrc,1);
Rdst = imresize(Rsrc,106*k/Rheight);
[Rheight,Rwidth,~]=size(Rdst);
bgWithR = ImgInsert(bg,Rdst,size(bg,1)/2-Rheight/2,size(bg,2)/2-Rwidth/2);

% imshow(Rdst);

% imshow(insertRotateArmor(bgWithR,states,0,0.5));



t = 0:1/f:t_max;
omega = 0.785*sin(1.884*t)+1.305;
angles = cumsum(omega/f);

aviobj = VideoWriter('example.avi');
aviobj.FrameRate = f;
open(aviobj)


for i = angles
    frame = insertRotateArmor(bgWithR,states,i,0.5);
    writeVideo(aviobj,frame);
%     imshow(frame);
    fprintf("%.2f%%\n",i/t_max*100);
end
close(aviobj)


%% ����
function y = insertRotateArmor(src,states, theta,k)
    % src: �������ԭͼ��
    % states: ���װ�װ������
    % theta: ��糵��ת�ĽǶ�
    global activatedArmorSRC;
    global targetArmorSRC;
    global unactivatedArmorSRC;
    global baseAngles;
    % ����װ�װ�
    for i=1:5
        state = states(i);
        angle = baseAngles(i)+theta;
        switch state
            case 0
                src = insertMonoArmor(src,unactivatedArmorSRC,angle,k);
            case 1
                src = insertMonoArmor(src,targetArmorSRC,angle,k);
            case 2
                src = insertMonoArmor(src,activatedArmorSRC,angle,k);
        end
    end
    
    % ����R
%     global Rsrc; 
    
    y=src;
 % src��Ҫ����ı���ͼ��
end

function y=insertMonoArmor(src,armorSRC,theta,k)
    % src: �������ԭͼ��
    % states: װ�װ�ͼ��
    % theta: װ�װ���ת�ĽǶ�
    [h1,w1,~] = size(armorSRC);
    [h2,w2,~] = size(src);
    
    o1c1 = [54/47*h1;w1/2];
    o2c2 = [h2/2;w2/2];
    RotationMatrix = [cos(theta), sin(theta);-sin(theta),cos(theta)];
    
    for i = 1:h1
        for j = 1:w1
            o1p1 = [i;j];
            if armorSRC(o1p1(1),o1p1(2),1)==0
                continue
            end
            o2p3 = floor(o2c2 + RotationMatrix*800*k/(54/47*h1)*(-o1c1+o1p1));
            
            if o2p3(1)>0 && o2p3(1)<h2 && o2p3(2)>0 && o2p3(2)<w2
                src(o2p3(1),o2p3(2),:) = armorSRC(o1p1(1),o1p1(2),:);
            end
        end
    end
    
    y = src;
end

function outputImg=ImgInsert(bgImg, subImg, leftTopPixelRow, leftTopPixelCol)
    leftTopPixelRow = floor(leftTopPixelRow);
    leftTopPixelCol = floor(leftTopPixelCol);
    outputImg=bgImg;
    [subHeight, subWidth,~] = size(subImg);
    outputImg(leftTopPixelRow:leftTopPixelRow+subHeight-1, leftTopPixelCol:leftTopPixelCol+subWidth-1, :) = subImg(:, :, :);
end
