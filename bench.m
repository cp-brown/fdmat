profile -memory on
for d = [1,2,3,10,20,30,100]
    for N = [40,400,4000]
        pts = CreatePoints(N, d, 'r');

        for j = 1:10
            %distancematrix_ref(pts, pts);
            distancematrix(pts, pts);
            distancematrixf(pts);
            disp([d,N,j]);
        end

    end
end
profile off
profile viewer