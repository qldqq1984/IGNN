import os
import os.path as osp
import  pandas  as pd
import math
import random
import bitarray as bit_opt
import warnings
from natsort import natsorted
from experiment_utils.experiment_utils import seed_everything

seed_everything( seed = 20);

warnings.filterwarnings("ignore")
path = osp.join(osp.dirname(osp.realpath(__file__)), 'data', 'CDTM_G')

"""
pip install dec2bin
pip install lifelines
pip install natsort
pip install openpyxl
pip install bitarray
"""


def edgeWeight(node1_attr, node2_attr, bit_n):
    
    attr = node1_attr | node2_attr
    attr_b = "{0:b}".format(attr)
    attr_b = bit_opt.bitarray(attr_b)
    attr_num = sum(attr_b)
    
    attr_sim = node1_attr & node2_attr
    attr_sim_b = "{0:b}".format(attr_sim)
    attr_sim_b = bit_opt.bitarray(attr_sim_b)
    attr_sim_num = sum(attr_sim_b)
    
    if attr_num == 0:
        weight = 1
        return weight
    
    weight = attr_sim_num/attr_num
    
    return weight


PATIENT_INFO_DIR = "G:/博士论文5/NC_review1/IGNNandIGNNE_final_v1/experiments/Patients_Information/DataSets_souce/"
New_PATIENT_INFO_DIR = "G:/博士论文5/NC_review1/IGNNandIGNNE_final_v1/experiments/Patients_Information/DataSets_new/"   
# New_RESERVE_PATIENT_INFO_DIR = "G:/博士论文5/NC_review1/IGNNandIGNNE_final_v1/experiments/Patients_Information/DataSets_new_reserve/"  
New_RESERVE_PATIENT_INFO_DIR = "G:/博士论文5/NC_review1/IGNNandIGNNE_final_v1/experiments/Patients_Information/DataSets_demo/"  

node_indexs_key = 0; node_labels_key = 1; Graph_id_key = 2; Class_id_key = 3;
TACS_8_key = 4;
TACS_7_key = 5;
TACS_6_key = 6; 
TACS_5_key = 7; 
TACS_4_key = 8; 
TACS_3_key = 9; 
TACS_2_key = 10;
TACS_1_key = 11; 
DFS_key = 12; No_key = 13; type_key = 14; size_key = 15; lym_key = 16; stage_key = 17; grade_key = 18; age_key = 19; STATUS_key = 20;
ER_key = 22; PR_key = 23; HER2_key = 24;
Chemotherapy_key = 27; Endocrine_key = 28; Radiation_key = 29; Targeted_key = 30; 
    
total_graphs_index = 0;
total_nodes_index = 0;
# No_id_match_total_graphs_index = [];   

for dir_i in range(1,3):        
    PatientInfo_dir = PATIENT_INFO_DIR + 'class_{:01d}/'.format(dir_i)
    New_PatientInfo_dir = New_PATIENT_INFO_DIR + 'class_{:01d}/'.format(dir_i)
    New_RESERVE_PatientInfo_dir = New_RESERVE_PATIENT_INFO_DIR + 'class_{:01d}/'.format(dir_i)
    print("PatientInfo_dir..",PatientInfo_dir)   
          
    patirnt_files = os.listdir(PatientInfo_dir);
    patirnt_files = natsorted(patirnt_files)
    index = 1
    for graphs_num in range (1, len(patirnt_files) + 1):
        # print("graphs_num..",graphs_num)
        INFO_TABLE = pd.read_excel ( PatientInfo_dir + patirnt_files[graphs_num-1] )
        rows = INFO_TABLE.shape[0];
        cols = INFO_TABLE.shape[1];        
        num_ROI = rows;
        
        if num_ROI >= 12 :
            num_delete_ROI = math.floor( num_ROI * 0.2 )
            reserve_ROI_id = random.sample(range(2,num_ROI),num_ROI - num_delete_ROI-1)
            reserve_ROI_id.append(1)
            reserve_ROI_id.sort()
            
            New_INFO_TABLE = INFO_TABLE 
            New_RESERVE_INFO_TABLE = INFO_TABLE.loc[INFO_TABLE['node_indexs'].isin(reserve_ROI_id) ]
            New_RESERVE_INFO_TABLE['node_indexs'] = [i for i in range(1,num_ROI - num_delete_ROI + 1)]
            print("reserve_ROI_id..",reserve_ROI_id)
            # print(New_RESERVE_INFO_TABLE)
            # hhhh
            print(patirnt_files[graphs_num-1], "n ({:d}).xlsx".format(index))
            # New_INFO_TABLE.to_excel(New_PatientInfo_dir + patirnt_files[graphs_num-1], sheet_name="1", index=False)    
            # New_RESERVE_INFO_TABLE.to_excel(New_RESERVE_PatientInfo_dir + patirnt_files[graphs_num-1], sheet_name="1", index=False)
            # New_INFO_TABLE.to_excel(New_PatientInfo_dir + "n ({:d}).xlsx".format(index), sheet_name="1", index=False)    
            New_RESERVE_INFO_TABLE.to_excel(New_RESERVE_PatientInfo_dir + "n ({:d}).xlsx".format(index), sheet_name="1", index=False)            
            index += 1
     
          


        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        