%% Simple script for parsing eLogbook data to d3js for visualisation

%load data
load();

%set variables
Dates = [year(OperationDate) month(OperationDate)]; %operations in years & months
LogbookPeriod = zeros(1, length(unique(year(OperationDate))) * 12); %how long have you been operating?
nCases = length(OperationDate); %how many cases?
OpTypes = unique(Operation); %what different cases have you done?

%run loop
logbook_matrix = zeros(length(OpTypes), length(LogbookPeriod)); %cases by dates matrix
for iCase = 1:nCases %for each case
    Op = Operation{iCase}; %what case was it
    OpIndex = strcmp(Op, OpTypes); %get index value for case type
    OpIndex = find(OpIndex==1);
    OpDate = Dates(iCase, :); %when was the case performed
    OpDate = OpDate(1, 2) + 12 .* (OpDate(1, 1) - min(Dates(1, 1))); %date in months since started
    logbook_matrix(OpIndex, OpDate) = logbook_matrix(OpIndex, OpDate) + 1; %enter data to matrix    
end

%parse data to appropriate format
[row_id, col_id] = find(logbook_matrix~=0); %get indices of entries
[~, I] = sort(row_id, 'ascend'); %get row order for later
entries = logbook_matrix(logbook_matrix>0);
parsed = [row_id col_id entries]; %in default row first order
parsed = parsed(I, :); %put in order of columns (dates)

%write case numbers & occurences
dlmwrite('~/Desktop/logbook_parsed.tsv', parsed, 'delimiter', '\t'); %save as .tsv

%write case types
fileID = fopen('~/Desktop/logbook_casetypes.txt','w');
for iRow = 1:length(OpTypes);
    fprintf(fileID, '''%s'', ', OpTypes{iRow});
end

%write dates
y = [min(year(OperationDate)):max(year(OperationDate))];
Y = reshape(y(ones(1,12),:), 120, 1)' %indexing method
m = [01:12];
M = repmat(m, 1, length(y));
D = [01];
t = datetime(Y, M, D, 'Format', 'yyyy MMMM')

%write 
fileID = fopen('~/Desktop/logbook_casedates.txt','w');
str = char(t);
for iRow = 1:length(t);
    fprintf(fileID, '''%s'',', str(iRow, :));
end

fprintf(fileID, '%s', t); 

%save('~/Desktop/logbook_casetypes.txt', 'OpTypes'); 
