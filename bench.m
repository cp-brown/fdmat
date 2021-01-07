profile -memory on
for d = [1,2,3,10,20,30,100]
    for N = [40,400,4000]
        dsites = CreatePoints(N, d, 'r');
        cntrs = CreatePoints(N, d, 'r');

        for j = 1:10
            %distancematrix_ref(pts, pts);
            distancematrix(dsites, cntrs);
            distancematrixf(dsites, cntrs);
            distancematrix(dsites, dsites);
            distancematrixf(dsites);
            disp([d,N,j]);
        end

    end
end
profile off
profile viewer