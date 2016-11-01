%______________________________ELEC 221 Project___________________________%

%% Task 1 Frames Extraction
v = VideoReader('NASA | The Arctic and the Antarctic Respond in Opposite Ways.mp4');
lastFrameIndex = 340;
render = false;
close all;

%%What is the total number of frames in the video?
disp(['Q0: There are ' num2str(v.NumberOfFrames) ' frames in the video.'])

%What is the frame rate?
disp(['Q0: The frame rate is ' num2str(v.FrameRate) ' frames per second.'])

%Read all the frames from the video file using the function ?readFrame?.
%Save each frame into an image file with PNG format using the function
%?imwrite?.
%Interested in frames between 0:45 and 0:56.

v = VideoReader('NASA | The Arctic and the Antarctic Respond in Opposite Ways.mp4');
v.CurrentTime = 45.315; %start 45.3 seconds in
frameIndex = 0;
if(render)
    while hasFrame(v)
        frame = readFrame(v);
        imwrite(frame, ['data/rgb/NASAFrame' num2str(frameIndex) '.png']);
        
        if(v.CurrentTime > 56.68) %end 56.8 seconds in
            break
        end
        frameIndex = frameIndex + 1;
    end
end

%What is the size (number of rows, columns...) of the data array
%representing each frame?
disp(['Q1: The data array has ' num2str(v.Height) ' rows and ' num2str(v.Width) ' columns.'])

%What is the height and width (in terms of number of pixels) in each frame?
disp(['Q1: The video is ' num2str(v.Height) ' pixels high and ' num2str(v.Width) ' pixels wide.'])

%What is the number of bits per pixel in a true color (RGB) image?
disp(['Q1: The number of bits per pixel is ' num2str(v.BitsPerPixel) ' in a RGB image.'])

%% Task 2 Conversion to Grayscale
%Convert each RGB frame to grayscale.
if(render)
    for i = 0:lastFrameIndex
        rgbImage = imread(['data/rgb/NASAFrame' num2str(i) '.png']);
        grayscaleImage = rgb2gray(rgbImage);
        imwrite(grayscaleImage, ['data/grey/NASAFrameGrey' num2str(i) '.png']);
    end
end

%What is the number of bits per pixel in a grayscale image?
disp(['Q2: The number of bits per pixel is ' num2str(8) ' in a grayscale image.'])

%Use MATLAB's imshow function to display the frame stamped with the date
%?April X, 2014?, in grayscale.
X = mod(47, 30) + 1;
disp(['Fig 1: Greyscale image with the date April ' num2str(X) ', 2014.'])
figure;
imshow(['data/grey/NASAFrameGrey' num2str(53) '.png']); %hardcoded index value

%% Task 3 Conversion to Black and White
%Convert grayscale images to binary ones.
if(render)
    for j = 0:lastFrameIndex
        grayscaleImage = imread(['data/grey/NASAFrameGrey' num2str(j) '.png']);
        blackwhiteImage = imbinarize(grayscaleImage);
        imwrite(blackwhiteImage, ['data/blackwhite/NASAFrameBW' num2str(j) '.png']);
    end
end

%Use the?imshow? function to display the frame stamped with the date ?April
%X, 2014? in black and white.
disp(['Fig 2: Black and white image with the date April ' num2str(X) ', 2014.'])
figure;
imshow(['data/blackwhite/NASAFrameBW' num2str(53) '.png']); %hardcoded index value

%% Task 4 Masking out the Date Stamp
% Remove the date stamp from the top left of each frame.
if(render)
    for k = 0:lastFrameIndex
        blackwhiteImage = imread(['data/blackwhite/NASAFrameBW' num2str(k) '.png']);
        
        %loop to overwrite rectangle with date to just black -> 0 values
        startRowPixel = 48;
        endRowPixel = 84;
        startColumnPixel = 98;
        endColumnPixel= 266;
        
        dateRemovedImage = blackwhiteImage;
        dateRemovedImage(startRowPixel:endRowPixel, startColumnPixel:endColumnPixel) = 0;
     
        imwrite(dateRemovedImage, ['data/dateremoved/NASAFrameDR' num2str(k) '.png']);
    end
end

%Use the imshow function to display the frame after masking out the date.
disp('Fig 3: Black and white image with the date masked out.')
figure;
imshow(['data/dateremoved/NASAFrameDR' num2str(53) '.png']); %hardcoded index value

%% Task 5 Spatial Filtering
%Use MATLAB's imfilter function, along with an averaging filter of ap-
%propriate size N , in order to eliminate/reduce black pixels inside the
%white region in each frame.
N = 5;
filter = ones(N,N)/N^2;
numTimes = 40;

if(render)
    for l = 0:lastFrameIndex
        dateRemovedImage = imread(['data/dateremoved/NASAFrameDR' num2str(l) '.png']);
        filteredImage = dateRemovedImage;
        
        %loop to filter numTimes
        for f = 0:numTimes
            filteredImage = imfilter(filteredImage, filter);
        end
        
        imwrite(filteredImage, ['data/filtered/NASAFrameFiltered' num2str(l) '.png']);
        
        %{
        pic = imread(['data/dateremoved/NASAFrameDR' num2str(l) '.png']);
        pic2 = imread(['data/filtered/NASAFrameFiltered' num2str(l) '.png']);
        
        imshowpair(pic, pic2);
        %}
    end
end

%What is the size N of the averaging filter you use?
disp(['Q7: The filter used is of size ' num2str(N) '.'])

%How many times do you apply the filter for each frame?
disp(['Q7: The filter is applied ' num2str(numTimes) ' times.'])

%Use MATLAB's imshow function to display the frame from Task 4 after
%applying the averaging filter.
disp('Fig 4: Filtered image with the date masked out.')
figure;
imshow(['data/filtered/NASAFrameFiltered' num2str(53) '.png']); %hardcoded index value

%Use MATLAB's fft2 function to find the two-dimensional discrete Fourier
%transform (DFT) of your averaging filter.
fftFilter = fft2(filter);

%% Task 6 Estimate the Change in Ice Extent
%%Plot the change in ice area compared to its value at the beginning of the
%%duration.
iceContents = zeros([lastFrameIndex 1]);

for m = 0:lastFrameIndex
    filteredImage = imread(['data/filtered/NASAFrameFiltered' num2str(m) '.png']);
    
    iceContent = sum(sum(filteredImage));
    iceContents(m+1, 1) = iceContent;
end

initialIceContent = iceContents(1,1);
changeInIceContents = ((iceContents - initialIceContent)./initialIceContent);
dates = linspace(1, 183, 341);

disp('Fig 5: Change in ice area from March 21 to September 19, 2014.')
figure;
plot(dates, 100*changeInIceContents);
ylabel('Percent Change in Ice Area');
xlabel('Date from March 21, 2014 to September 19, 2014');
title('Change in Ice Area');

%% Task 7 Polynomial Regression
% Use an appropriate polynomial function of order n ? 1 that models the
% change in ice area over time.

p = polyfit(dates', 100*changeInIceContents, 2);

%Plot the polynomial fit in addition to the data points you obtained in
%Task 6.
disp('Fig 6: Change in ice area from March 21 to September 19, 2014.')
figure;
plot(dates, 100*changeInIceContents);
ylabel('Percent Change in Ice Area');
xlabel('Date from March 21, 2014 to September 19, 2014');
title('Change in Ice Area');
hold on;

modelDates = linspace(1, 200, 200); 
model = polyval(p, modelDates);
plot(modelDates, model);
legend('Data Points', 'Polynomial Fit', 'Location', 'southeast');

hold off;

%Write down the polynomial function you use.
disp(['Q10: The polynomial function is ' num2str(p(1)) 'x^2 + ' num2str(p(2)) 'x + ' num2str(p(3)) '.'])

%Use your polynomial regression model to predict ice coverage on Sep 30,
%2014. September 30th, 2014 is 194 days from March 21th, 2014.
disp(['Q11: The predicted ice coverage is %' num2str(model(194)) '.'])

%% Task 8 Data Collection and Mining
%Download the Daily Antarctic Sea Ice Extent dataset.
downloadedData = xlsread('data/SH_seaice_extent_final_v2.xlsx', 'A11203:D11567');
iceExtentData = downloadedData(:,4);

% Plot the daily ice extent data for the entire year of 2014, i.e., ice
% extent in millions of square kilometers versus the number of days (1 ? 365).
daysIn2014 = linspace(1, 365, 365);

disp('Fig 7: Daily Ice Extent in 2014')
figure;
plot(daysIn2014, iceExtentData);
ylabel('Extent in Millions of Square Kilometers');
xlabel('Days in 2014');
title('Daily Ice Extent in 2014');

%State the minimum and maximum ice extent (in millions of square kilome-
%ters) throughout the year 2014 along with the corresponding dates.
t = datetime(2014, 1, 1);
[minIceExtent, minDateIndex] = min(iceExtentData);
[maxIceExtent, maxDateIndex] = max(iceExtentData);

minDate = t + days(minDateIndex);
maxDate = t + days(maxDateIndex);

disp(['Q12: The minmum ice extent is ' num2str(minIceExtent) ' millions of square kms on ' datestr(minDate) '.'])
disp(['Q12: The maximum ice extent is ' num2str(maxIceExtent) ' millions of square kms on ' datestr(maxDate) '.'])

%Plot the percentage change in ice extent from Mar 21, 2014 till Sep 19,
%2014.
startDate = datetime(2014, 3, 21);
endDate = datetime(2014, 9, 19);

startDateIndex = 79; %daysact(t, startDate);
endDateIndex = 261; %daysact(t, endDate);

relevantIceExtentData = iceExtentData(startDateIndex:endDateIndex, :);
initialIceExtent = relevantIceExtentData(1,1);
percentageChangeData = ((relevantIceExtentData - initialIceExtent)./initialIceExtent);
datesData = linspace(1, endDateIndex-startDateIndex+1, endDateIndex-startDateIndex+1);

disp('Fig 8: Change in ice extent from March 21 to September 19, 2014.')
figure;
plot(datesData, 100*percentageChangeData);
ylabel('Percent Change in Ice Extent');
xlabel('Date from March 21, 2014 to September 19, 2014');
title('Change in Ice Extent');
