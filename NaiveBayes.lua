-- Ahmad Arsyel 1301164193
--- Prepare data
local TRAIN_PATH = "D:/Telkom University/Machine Learning/Tupro1/TrainsetTugas1ML.csv"
local TEST_PATH = "D:/Telkom University/Machine Learning/Tupro1/TestsetTugas1ML.csv"
local ANSWER_PATH = "D:/Telkom University/Machine Learning/Tupro1/TebakanTugas1ML.csv"

-- @param table Print traverse of table
local function print_table(table)
  for _, v in ipairs(table) do -- show parsing from CSV file
    print(v.id, v.age, v.workclass, v.education, v.status, v.occupation, v.relationship, v.hpw, v.income)
  end
end

-- @param path Use your path for .csv file
-- @return Table that contain parsed from CSV file (testset)
local function parse_testCSV(path)
  local tab_list = {}
  --print("load CSV file to table")
  -- output will saved in table_list
  for line in io.lines(path) do
    local col1, col2, col3, col4, col5, col6, col7, col8 = line:match(
        "%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*)") -- converting
        
    tab_list[#tab_list + 1] = {
      id = col1,
      age = col2,
      workclass = col3,
      education = col4,
      status = col5,
      occupation = col6,
      relationship = col7,
      hpw = string.sub(col8, 1, #col8-1),
      income = '?'
    }
  end
  table.remove(tab_list, 1) -- remove the title/header
  return tab_list
end

-- @param path Use your path for .csv file
-- @return Table that contain parsed from CSV file (trainset)
local function parse_CSV(path)
  local table_list = {}
  --print("load CSV file to table")
  -- output will saved in table_list
  for line in io.lines(path) do
    local col1, col2, col3, col4, col5, col6, col7, col8, col9 = line:match(
        "%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*),%s*(.*)") -- converting
    if (col9) then -- if col9 is exist
      if (#col9 == 5) then -- if read the string as 5
        col9 = 1 -- for income: >50K
      else
        col9 = 0 -- for income: <=50K
      end
    end
    
    table_list[#table_list + 1] = {
      id = col1,
      age = col2,
      workclass = col3,
      education = col4,
      status = col5,
      occupation = col6,
      relationship = col7,
      hpw = col8,
      income = col9
    }
  end
  table.remove(table_list, 1) -- remove the title/header
  return table_list
end

-- @param path Use your own path for .csv raw file targeted
-- @param data_table Saving file to .csv from data_table
-- @param sep Separator of file
local function table_to_CSV(path, data_table, sep)
  sep = sep or ','
  local file = assert(io.open(path, "w")) -- w mean write
  for _, v in ipairs(data_table) do
    file:write(v) -- v.y can be replaced (the solution column)
    file:write('\n')
  end
  file:close()
  print("file saved to CSV file\n")
end

-- @param table Table that reference to count
-- @param tab_type Key that reference to count
-- @param label Check 'if same' based on tab_type
-- @return Total from determine label
local function counting_label(table, tab_type, label)
  local sum = 0
  for _, v in ipairs(table) do -- show parsing from CSV file
    if (v[tab_type] == label) then
      sum = sum + 1
    end
  end
  return sum
end

-- @param tab_type Key that reference to count
-- @param val_to_count Label that would be checked
-- @param table Table that reference to count
local function p_output(val_to_count, tab_type, table)
  table = table or parse_CSV(TRAIN_PATH)
  tab_type = tab_type or "income"
  return counting_label(table, tab_type, val_to_count) / #table
end

-- @param tab_type Key that reference to count
-- @param label Check 'if same' based on tab_type
-- @param base_type To check the value of 'income' key
-- @param table Table that reference to count
local function counting_based(tab_type, label, base_type, table)
  table = table or parse_CSV(TRAIN_PATH)
  base_type = base_type or 0
  local sum = 0
  for _, v in ipairs(table) do -- show parsing from CSV file
    if ((v[tab_type] == label) and (v.income == base_type)) then
      sum = sum + 1
    end
  end
  return sum
end

-- @param table Table that reference
-- @param age..hpw Value from key that wanted to calculate
local function p_high_income(table, age, wclass, edu, stat, occ, rel, hpw)
  local c1_income = counting_label(table, "income", 1)
  return (counting_based("age", age, 1)/c1_income) *
    (counting_based("workclass", wclass, 1)/c1_income) *
    (counting_based("education", edu, 1)/c1_income) *
    (counting_based("status", stat, 1)/c1_income) *
    (counting_based("occupation", occ, 1)/c1_income) *
    (counting_based("relationship", rel, 1)/c1_income) *
    (counting_based("hpw", hpw, 1)/c1_income)
end

-- @param table Table that reference
-- @param age..hpw Value from key that wanted to calculate
local function p_low_income(table, age, wclass, edu, stat, occ, rel, hpw)
  local c0_income = counting_label(table, "income", 0)
  return (counting_based("age", age)/c0_income) *
    (counting_based("workclass", wclass)/c0_income) *
    (counting_based("education", edu)/c0_income) *
    (counting_based("status", stat)/c0_income) *
    (counting_based("occupation", occ)/c0_income) *
    (counting_based("relationship", rel)/c0_income) *
    (counting_based("hpw", hpw)/c0_income)
end

-- @param h_income Result of >50k calculated bayes
-- @param l_income Result of <=50k calculated bayes
-- @return Value of final result for target label
local function determine_income(h_income, l_income)
  local income = 0
  if (h_income > l_income) then
    income = 1
  end
  return income
end

--[[local function get_random_data_pos()
  local plain_tab = parse_CSV(TRAIN_PATH)
  local random_tab = {}
  while (#plain_tab > 0) do
    local random_idx = math.random(1, #plain_tab)
    table.insert(random_tab, table.remove(plain_tab, random_idx))
  end
  return random_tab
end

local function get_validation_data()
  local data_random = get_random_data_pos()
  print(#data_random, data_random[1].id)
end]]

-- MAIN PROGRAM
math.randomseed(os.time())
local data_train = parse_CSV(TRAIN_PATH)
local data_test = parse_testCSV(TEST_PATH)
local data_output = {}
print_table(data_train)
print_table(data_test)
print("total data_train:", #data_train)
print("total data_test:", #data_test, "\n")

--get_validation_data()

print("---\nWait for processing...")

for _, val in ipairs(data_test) do
  local more_than = p_high_income(data_train, val.age, val.workclass, val.education, val.status, val.occupation, val.relationship, val.hpw) * p_output(1)
  local less_equal = p_low_income(data_train, val.age, val.workclass, val.education, val.status, val.occupation, val.relationship, val.hpw) * p_output(0)
  local result = determine_income(more_than, less_equal)
  if (result == 1) then
    table.insert(data_output, ">50K")
  else
    table.insert(data_output, "<=50K")
  end
  print("ID " .. val.id .. " = " .. result)
end

table_to_CSV(ANSWER_PATH, data_output)
