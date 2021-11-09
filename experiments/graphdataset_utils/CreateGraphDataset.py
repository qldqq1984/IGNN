import os
import os.path as osp
import torch
import  pandas  as pd
import numpy as np
import bitarray as bit_opt
import warnings
from natsort import natsorted

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
    """
    Assigns the initial edge weight according to the 
    similarity of the initial features of the corresponding nodes.
    
    Args:
        node1_attr(int): node1 feature coding. Default: TACS coding
        node2_attr(int): node2 feature coding. Default: TACS coding
        bit_n(int): Number of bits within feature coding. Default: 8
        
    Returns:
        weight(int): Initial weight of the edge between node1 and node2.
    """   
    
    
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


def create_GraphDataset(args):
    """
    Generate graphdataset from TACS coding, clinical and follow up data of patients.
    
    Args:
        args(argparse.Namespace): all arguments for models and experiments.
        args.REBULIT_GRAPH_DATA_STATE(bool): Determines whether to rebuild the graphdataset from the raw data of patients.
                                             Default: False
        args.GRAPH_DATA_NAME(str): directory name of graphdataset.
                                   Default: "TACS_G"
        args.PATIENT_INFO_DIR(str): directory of raw data including TACS coding and clinical/follow-up information from patients.  
                                    Default: "../experiments/Patients_Information/DataSets_995/"
    """
    
    if (args.REBULIT_GRAPH_DATA_STATE == False):
        return
        
    DEVICE_GPU = ( torch.cuda.is_available() ) & (args.PROCESSUNIT_STATE=='GPU');
    global device
    device = torch.device('cuda' if DEVICE_GPU  else 'cpu')    
    torch.cuda.empty_cache()

    GraphDataset_dir = args.GRAPH_DATA_DIR + args.GRAPH_DATA_NAME + '/raw/'  
    
    fp1 =  open(GraphDataset_dir + '{:s}_A.txt'.format(args.GRAPH_DATA_NAME) ,"w+")
    fp2 = open(GraphDataset_dir + '{:s}_graph_labels.txt'.format(args.GRAPH_DATA_NAME) ,"w+")  
    fp3 = open(GraphDataset_dir + '{:s}_graph_indicator.txt'.format(args.GRAPH_DATA_NAME) ,"w+")        
    fp4 =  open(GraphDataset_dir + '{:s}_node_labels.txt'.format(args.GRAPH_DATA_NAME) ,"w+")                             
    fp5 =  open(GraphDataset_dir + '{:s}_node_attributes.txt'.format(args.GRAPH_DATA_NAME) ,"w+")                                                 
    # fp6 =  open(GraphDataset_dir + '{:s}_edge_labels.txt'.format(args.GRAPH_DATA_NAME) ,"w+")                               
    # fp7 = open(GraphDataset_dir + '{:s}_edge_attributes.txt'.format(args.GRAPH_DATA_NAME) ,"w+")                
    fp8 = open(GraphDataset_dir + '{:s}_node_attributes_ex.txt'.format(args.GRAPH_DATA_NAME) ,"w+")       
    fp9 =  open(GraphDataset_dir + '{:s}_node_attributes_DFS.txt'.format(args.GRAPH_DATA_NAME) ,"w+")                           
    fp10 = open(GraphDataset_dir + '{:s}_No_id.txt'.format(args.GRAPH_DATA_NAME) ,"w+")        
    fp11 =  open(GraphDataset_dir + '{:s}_node_attributes_STATUS.txt'.format(args.GRAPH_DATA_NAME) ,"w+")
       

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
        PatientInfo_dir = args.PATIENT_INFO_DIR + 'class_{:01d}/'.format(dir_i)
        print("PatientInfo_dir..",PatientInfo_dir)   
              
        patirnt_files = os.listdir(PatientInfo_dir);
        patirnt_files = natsorted(patirnt_files)
        
        for graphs_num in range (1, len(patirnt_files) + 1):
            # print("PatientInfo_dir + patirnt_files[graphs_num-1]..",PatientInfo_dir + patirnt_files[graphs_num-1])
            INFO_TABLE = pd.read_excel ( PatientInfo_dir + patirnt_files[graphs_num-1] )
            rows = INFO_TABLE.shape[0];
            cols = INFO_TABLE.shape[1];
            
            total_graphs_index = total_graphs_index + 1;
            
            # the number of nodes in each graph structure
            nodes_num = rows;  
            node_attributes_tmp = np.zeros( (1,nodes_num) );
            
            No_id = str(INFO_TABLE.values[0, No_key])
            Class_id = int(INFO_TABLE.values[0, Class_id_key])
            DFS = int(INFO_TABLE.values[0, DFS_key])
            STATUS = int(INFO_TABLE.values[0, STATUS_key])
            Graph_id = int(INFO_TABLE.values[0, Graph_id_key])       
              
            
            # create No_id.txt             
            fp10.write('{:s},{:s},{:d},{:d}\n'.format(PatientInfo_dir + patirnt_files[graphs_num-1], No_id, Class_id, Graph_id ))  
            
            
            # create graph_labels.txt  
            fp2.write('{:d}\n'.format(Class_id) )   
            
            
            # create graph_indicator.txt 
            for i in range(0, nodes_num ):
                fp3.write('{:d}\n'.format(total_graphs_index))  


            # create node_labels.txt 
            for i in range(0, nodes_num ):
                node_label = int(INFO_TABLE.values[i, node_labels_key])
                fp4.write('{:d}\n'.format(node_label))  
                
                
            # create node_attributes.txt containing the TACS coding of patients   
            for i in range(0, nodes_num ):   
                TACS_1 = int(INFO_TABLE.values[i, TACS_1_key])
                TACS_2 = int(INFO_TABLE.values[i, TACS_2_key])
                TACS_3 = int(INFO_TABLE.values[i, TACS_3_key])
                TACS_4 = int(INFO_TABLE.values[i, TACS_4_key])
                TACS_5 = int(INFO_TABLE.values[i, TACS_5_key])
                TACS_6 = int(INFO_TABLE.values[i, TACS_6_key])
                TACS_7 = int(INFO_TABLE.values[i, TACS_7_key])
                TACS_8 = int(INFO_TABLE.values[i, TACS_8_key])
                node_attributes = int( TACS_1 + (2*TACS_2)**1 + (2*TACS_3)**2 + (2*TACS_4)**3 + (2*TACS_5)**4 + (2*TACS_6)**5 + (2*TACS_7)**6 + (2*TACS_8)**7 );
                fp5.write('{:d}\n'.format(node_attributes))                 
                node_attributes_tmp[0, int(INFO_TABLE.values[i, node_indexs_key]-1) ] = node_attributes;

                
            # create node_attributes_ex.txt containing the clinical and follow-up data of patients
            molecular_type = int(INFO_TABLE.values[0, type_key])
            tumor_size = int(INFO_TABLE.values[0, size_key])
            Lymphnode_metastasis = int(INFO_TABLE.values[0, lym_key])
            clinical_stage = int(INFO_TABLE.values[0, stage_key])
            histological_grade = int(INFO_TABLE.values[0, grade_key])
            age = int(INFO_TABLE.values[0, age_key])            
            chemotherapy = int(INFO_TABLE.values[0, Chemotherapy_key])
            endocrine = int(INFO_TABLE.values[0, Endocrine_key])
            radiation = int(INFO_TABLE.values[0, Radiation_key])
            targeted = int(INFO_TABLE.values[0, Targeted_key])
            ER = int(INFO_TABLE.values[0, ER_key])
            PR = int(INFO_TABLE.values[0, PR_key])
            HER2 = int(INFO_TABLE.values[0, HER2_key])          
            fp8.write('{:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}, {:d}\n'.format(molecular_type, tumor_size, Lymphnode_metastasis, \
                                                                                                              clinical_stage, histological_grade, age, \
                                                                                                              chemotherapy, endocrine, radiation, targeted, \
                                                                                                              ER, PR, HER2, Graph_id )) 
            

            # create node_attributes_DFS.txt containing the DFS(month) of patients
            fp9.write('{:d}\n'.format(DFS) )   


            # create node_attributes_STATUS.txt containing the STATUS of patients
            fp11.write('{:d}\n'.format(STATUS) ) 
            

            # create A.txt containing the adjacency matrix with the initial weights of the edges for the graph structure 
            for n_i in range(1, nodes_num + 1):
                total_nodes_index = total_nodes_index + 1
                if (n_i == nodes_num):
                    break
                for n_j in range( n_i + 1, nodes_num + 1 ):
                    node_i_attr = int( node_attributes_tmp[0, n_i - 1] );
                    node_j_attr = int( node_attributes_tmp[0, n_j - 1] );
                    
                    # the initial weights of the edges for the graph structure 
                    weight = edgeWeight(node_i_attr, node_j_attr, 8);
                    if weight != 0:
                        fp1.write('{:d}, {:d}\n'.format(total_nodes_index, total_nodes_index + n_j - n_i ) )
                        fp1.write('{:d}, {:d}\n'.format(total_nodes_index + n_j - n_i, total_nodes_index ) )
                                            
                
    fp1.close()
    fp2.close()
    fp3.close()        
    fp4.close()        
    fp5.close()        
    # fp6.close()       
    # fp7.close()        
    fp8.close()        
    fp9.close()        
    fp10.close()        
    fp11.close()        
    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        