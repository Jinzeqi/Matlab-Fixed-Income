%% A. Construct Spot Curve Using Bond Price

%1. input the existing bond yiled and maturity
bond_data = xlsread('Bond.xlsx','sheet1');
t_bond = bond_data(:,1)';
y_bond = bond_data(:,2)';
%2. get the full maturity => prepare input for interpolation
int_bond = 0.5:0.5:t_bond(end);
%3. linear interpolation
l_y_bond = interp1(t_bond,y_bond,int_bond);
%4. cubic interpolatioz
c_y_bond = spline(t_bond,y_bond,int_bond);
%5. bootstrap for spot rate curve
spot_linear_bond = [y_bond(1:2),ones(1,length(int_bond)-2) * -1];
spot_cubic_bond = [y_bond(1:2),ones(1,length(int_bond)-2) * -1];
for i = 3 : length(int_bond)
    left_value_linear = 0;
    left_value_cubic = 0;
    for j = 1 : i-1
        left_value_linear = left_value_linear + l_y_bond(i)/2 * 100 / (1 + spot_linear_bond(j) / 2)^j;
        left_value_cubic = left_value_cubic + c_y_bond(i)/2 * 100 / (1 + spot_cubic_bond(j) / 2)^j;                
    end
    spot_linear_bond(i) = (((100 + l_y_bond(i)/2 * 100) / (100 - left_value_linear))^(1 / i) - 1) * 2; 
    spot_cubic_bond(i) = (((100 + c_y_bond(i)/2 * 100) / (100 - left_value_cubic))^(1 / i) - 1) * 2;     
end
%6. plot the yiled curve
figure(1)
subplot(2,1,1)
plot(int_bond,spot_linear_bond)
title('Spot rate from bond price by linear interpolation')
subplot(2,1,2)
plot(int_bond,spot_cubic_bond)
title('Spot rate from bond price by cubic interpolation')
%% B. Construct Spot Curve Using Current Swap Rate

%1. input the existing swap yiled and maturity
swap_data = xlsread('Swap.xlsx','sheet1');
t_swap = swap_data(:,1);
y_swap = swap_data(:,2) / 100;
%2. interpolate the swap yield data
int_swap = 0.5:0.5:t_swap(end);
l_y_swap = interp1([0.5,t_swap'],[y_swap(1)-(y_swap(2)-y_swap(1))/2,y_swap'],int_swap);
c_y_swap = spline([0.5,t_swap'],[y_swap(1)-(y_swap(2)-y_swap(1))/2,y_swap'],int_swap);
%3. calculate discount factor
df_l_swap = ones(1,length(int_swap)) * -1;
df_l_swap(1) = 100 / (100 + l_y_swap(1) * 100 / 2);
df_c_swap = ones(1,length(int_swap)) * -1;
df_c_swap(1) = 100 / (100 + c_y_swap(1) * 100 / 2);
for i = 2:length(int_swap)
    df_l_swap(i) = (100 - repmat(l_y_swap(i) * 100 / 2, 1, i-1) * df_l_swap(1:i-1)') / (100 + l_y_swap(i) * 100 / 2);
    df_c_swap(i) = (100 - repmat(c_y_swap(i) * 100 / 2, 1, i-1) * df_c_swap(1:i-1)') / (100 + c_y_swap(i) * 100 / 2);
end
%4. calculte spot rate
sr_l_swap = ones(1,length(df_l_swap)) * -1;
sr_c_swap = ones(1,length(df_c_swap)) * -1;
for i = 1:length(df_l_swap)
    sr_l_swap(i) = 2 * ((1 / df_l_swap(i))^(1 /(2 * int_swap(i))) - 1);
    sr_c_swap(i) = 2 * ((1 / df_c_swap(i))^(1 /(2 * int_swap(i))) - 1);    
end
%5. plot the yiled curve
figure(2)
subplot(2,1,1)
plot(int_swap,sr_l_swap)
title('Spot rate from swap rate by linear interpolation')
subplot(2,1,2)
plot(int_swap,sr_c_swap)
title('Spot rate from swap rate by cubic interpolation')
%% D. Perform Principal Component Analysis for Treasure Yield Curve

%1. input the treasury data into workspace
load x
%2. calculte the pca 
t_data_1 = data_1;
[coee_1,score_1,latent_1,tsquared_1,explained_1] = pca(t_data_1);
t_data_2 = data_2;
[coee_2,score_2,latent_2,tsquared_2,explained_2] = pca(t_data_2);