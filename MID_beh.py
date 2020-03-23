# School study baseline fmri behavioral analysis (from log)

# Sarah Hennessy, 2020

import os
import sys
import csv
import pandas as pd
import numpy as np
import glob
import math

import warnings
warnings.filterwarnings("ignore")

def score(log, outpath):
    all_folders = glob.glob(log + '/*')

    #all_files = glob.glob(log + '/*/*.txt')
    outfilename = outpath + "/fmri_MID_beh.csv"

    exists = os.path.isfile(outfilename)
    if exists:
        overwrite = input('stop! this file already exists! are you sure you want to overwrite? y or n: ')
        if overwrite == 'n':
            print('ok. quitting now.')
            return


#1 music, #2 control
    control = ['203AG', '205SD', '206RP', '207KM', '208BJ', '211MA', '212ZA', '216CB', '218CS', '220JM', '224SM', '231JA', '232AG', '233AS', '234DL', '503JM', '504AD', '505GM', '507LA', '510DC', '514EG', '519YI', '521SG', '526CU', '539IF', '540MM', '546AO', '547BA', '554CT', '555PT', '559NM', '560KS', '561JA', '564LD', '565AZ', '569AM', '571LA', '572BL', '573EP', '574SU', '575CV', '577NM', '578JS', '579WN']
    music = ['201SN', '202JR', '204DL', '209BM', '210DC', '213JB', '214ER', '215BM', '219EM', '226FC', '227KT', '235SM', '237XA', '238AP', '501LD', '502FT', '506FA', '509KL', '513GB', '517GR', '518DH', '522SG', '527RC', '528AE', '529SA', '530PG', '532MN', '541IG', '542JL', '543ZP', '545KL', '548DM', '549BA', '552JG', '553LL', '556GL', '558AM', '562SE', '566EB', '567GO', '570GR', '580KM']


    #create a new dataframe
    colnames = ['id','year','group','win_small_accuracy', 'lose_small_accuracy', 'neutral_neutral_accuracy', 'win_small_RT', 'lose_small_RT', 'neutral_neutral_RT', 'win_large_accuracy', 'lose_large_accuracy', 'win_large_RT', 'lose_large_RT', 'earned'] #make columns

    newdf = pd.DataFrame(columns = colnames) #create df

    for folder in all_folders:

        print("Running...: %s" %(folder[-5:]))

        files = glob.glob(folder + '/*.txt')

        id = folder[-5:]

        if id in control:
            group = 'control'
        if id in music:
            group = 'music'



        win_small_accuracy_li = []
        lose_small_accuracy_li = []
        win_small_RT_li = []
        lose_small_RT_li = []
        neutral_neutral_accuracy_li = []
        neutral_neutral_RT_li = []
        win_large_accuracy_li = []
        lose_large_accuracy_li = []
        win_large_RT_li = []
        lose_large_RT_li = []
        earned_li = []



        for filename in files:
            data = pd.read_csv(filename,delim_whitespace = True, comment = "#", header = "infer", skip_blank_lines = True, engine = "python")
            idfull = data.record_id[0]
            run = filename[-5]
            print('processing %s run %s' %(id,run))

            if "baseline" in idfull:
                year = 'baseline'
            if "year2" in idfull:
                year = 'year1'
            if "year4" in idfull:
                year = 'year4'

            #print(year)
            #print(data)
            #print(data.condition)


            for index, row in data.iterrows():


                if row.condition == "win":

                    if row.level == "small":

                        win_small_accuracy_li.append(row.accuracy)
                        if row.accuracy == 1:
                            win_small_RT_li.append(row.rt)

                    elif row.level == "large":
                        win_large_accuracy_li.append(row.accuracy)

                        if row.accuracy == 1:

                            win_large_RT_li.append(row.rt)



                elif row.condition == "lose":

                    if row.level == "small":

                        lose_small_accuracy_li.append(row.accuracy)

                        if row.accuracy == 1:

                            lose_small_RT_li.append(row.rt)

                    elif row.level == "large":
                        lose_large_accuracy_li.append(row.accuracy)
                        if row.accuracy == 1:
                            lose_large_RT_li.append(row.rt)

                elif row.condition == "neutral":

                    neutral_neutral_accuracy_li.append(row.accuracy)
                    if row.accuracy == 1:
                        neutral_neutral_RT_li.append(row.rt)
                else:
                    continue

                earned_li.append(row.earned)

                #print(go_accuracy_li[-1:])
                #print(go_RT_li[-1:])

        win_small_accuracy= np.mean(win_small_accuracy_li)
        lose_small_accuracy = np.mean(lose_small_accuracy_li)
        win_small_RT = np.mean(win_small_RT_li)
        lose_small_RT = np.mean(lose_small_RT_li)
        neutral_neutral_accuracy = np.mean(neutral_neutral_accuracy_li)
        neutral_neutral_RT = np.mean(neutral_neutral_RT_li)
        win_large_accuracy = np.mean(win_large_accuracy_li)
        lose_large_accuracy = np.mean(lose_large_accuracy_li)
        win_large_RT = np.mean(win_large_RT_li)
        lose_large_RT = np.mean(lose_large_RT_li)
        earned = np.mean(earned_li)




        newdf = newdf.append({'id': id,'year': year,'group': group,'win_small_accuracy':win_small_accuracy , 'lose_small_accuracy':lose_small_accuracy, 'neutral_neutral_accuracy':neutral_neutral_accuracy, 'win_small_RT':win_small_RT, 'lose_small_RT':lose_small_RT, 'neutral_neutral_RT':neutral_neutral_RT, 'win_large_accuracy':win_large_accuracy, 'lose_large_accuracy':lose_large_accuracy, 'win_large_RT':win_large_RT, 'lose_large_RT':lose_large_RT, 'earned':earned},ignore_index=True)


    newdf.to_csv(outfilename,index =False)

    print('congrats! you are now done with stop fmri beh (MID) scoring.')


if __name__ == '__main__':
    # Map command line arguments to function arguments.
    try:
        score(*sys.argv[1:])
    except:
        print("you have run this incorrectly!To run, type:\n \
        'python3.7 [name of script].py [full path of RAW DATA] [full path of output folder]'")
