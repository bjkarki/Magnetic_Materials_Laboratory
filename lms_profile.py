def surface_profile(cleaned_file,offset,start_angle=0,savefig=False) :
    """Surface_profile plots surface profile vs magnetic fiel orientatation.
    the plots are vertically stacked"""
    
    # Import required packages
    import pandas as pd
    import numpy as np

    import matplotlib.pyplot as plt
    
    # read outputfile and show few rows
    df=pd.read_excel(cleaned_file)
    
    ##color palette
    color=plt.cm.winter(np.linspace(0, 1, 20)) #we only need 20

    ##offset array
    offset=[offset*i for i in range(df.shape[1])]

    ##annotation labels
    #the motor rotate rotates on a step of 10 upto 200 for complete rotation 
    label=[str(start_angle+int(num/20 * 360))+'$^\circ$' for num in range(df.shape[1])]

    
    ###Define figure and ax object
    fig, ax = plt.subplots()

    ##fig size
    fig.set_size_inches([6,12])
    
    ##x-axis for all figures
    x= df['distance'].values
    
    ## Loop for line plot, fill and labels
    for i,j in enumerate(df.columns[:-1]):
    
        #y-axis for each loop
        y= df[j].values + offset[i]
        if i == 0 : ymin = y.min()
    
        #line plot
        ax.plot(x, y,
                c=color[i], linewidth=2)
    
        #fill when below baseline
        ax.fill_between(x,y,
                        y2=offset[i], where=y<offset[i],
                        color=color[i], alpha=0.4)
        #annotate
        ax.annotate(label[i],
                    [x.max(),offset[i]],
                    c=color[i])

    # use scientific notation in y-axis
    plt.ticklabel_format(axis="y", style="sci", scilimits=(0,0))
    ax.yaxis.major.formatter._useMathText = True

    # axis label
    ax.set_xlabel('location (mm)')
    ax.set_ylabel('elevation (mm)')
    ax.set_title('Surface Profile')
    ax.set_xlim([x.min(),x.max()])
    ax.set_ylim([ymin-0.002,y.max()+0.002])

    # Hide the right and top spines
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)

    #grid
    plt.grid(color='gray', linestyle='-', linewidth=0.4, alpha=0.6)

    #show
    plt.show()
    
    #save
    if savefig : fig.savefig('output.png', dpi = 150)
    
CTforward = 'Coarse Twins (CT)/01. ForwardTest/output/CTForward_cleaned.xlsx'
offset = 0.018
MPforward = 'Micro Peened (MP)/Test1/01. FR_100cycle/FilteredOutput_FR_100cycle.xlsx'