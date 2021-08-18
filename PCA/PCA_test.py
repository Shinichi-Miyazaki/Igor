import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import tkinter
from tkinter import filedialog
from tkinter import messagebox
from sklearn.decomposition import PCA
import matplotlib.ticker as ticker
from sklearn.cluster import KMeans


"""
To do 
指紋領域のみでPCA 
"""


extracted_class_num = 15
x = 401
y = 101


def ask_directory():
    root = tkinter.Tk()
    root.withdraw()
    messagebox.showinfo('select file', 'select analyzing file')
    image_file_path = tkinter.filedialog.askopenfilename()
    image_directory = os.path.dirname(image_file_path)
    os.chdir(image_directory)
    messagebox.showinfo('select file', 'select analyzing file')
    axis_path = tkinter.filedialog.askopenfilename()
    return image_file_path, axis_path


def PCA_analysis(image_file_path, axis_path):
    data = pd.read_csv(image_file_path, header=None).T[0:x*y]
    x_axis = np.loadtxt(axis_path)
    # data normalization
    norm_data = data.iloc[:, 1:].apply(lambda x: (x - x.mean()) / x.std(), axis=0)
    pca = PCA()
    pca.fit(norm_data)
    feature = pca.transform(norm_data)
    data_PCA = pd.DataFrame(feature,
                            columns=["PC{}".format(x + 1) for x in range(len(norm_data.columns))])

    # make graph for PC scatter
    os.makedirs("./figures", exist_ok=True)
    plt.figure(figsize=(6, 6))
    plt.scatter(feature[:, 0], feature[:, 1], alpha=0.8, color="black")
    plt.grid()
    plt.xlabel("PC1")
    plt.ylabel("PC2")
    plt.grid(False)
    plt.savefig("./figures/PCA_scatter_bd.png", transparent=True)

    # make graph for CDF
    plt.figure(figsize=(8, 5))
    pd.DataFrame(pca.explained_variance_ratio_, index=["PC{}".format(x + 1) for x in range(len(norm_data.columns))])
    plt.gca().get_xaxis().set_major_locator(ticker.MaxNLocator(integer=True))
    plt.plot([0] + list(np.cumsum(pca.explained_variance_ratio_)), "-o",
             color="black")
    plt.xlabel("Number of principal components")
    plt.ylabel("Cumulative contribution rate")
    plt.grid()
    plt.xlim(0, 15)
    plt.grid(False)
    plt.savefig("./figures/PCA_CDF_bd.png", transparent=True, bbox_inches="tight", pad_inches=0.1)

    # clustering and
    extracted_df = data_PCA.iloc[:, 0:extracted_class_num]
    cust_array = extracted_df.to_numpy()
    cust_array = cust_array
    pred = KMeans(n_clusters=extracted_class_num).fit_predict(cust_array)
    pred_image = np.reshape(pred, [x, y])
    plt.imsave('./figures/predicted.png', pred_image)

    # class differentiation
    os.makedirs("./spectrum", exist_ok=True)
    Class_list = []
    for i in range(extracted_class_num):
        Class_list.append(np.where(pred != i, 0, 1))

    for i in range(extracted_class_num):
        fig, ax = plt.subplots()
        Class_data = data.T * Class_list[i]
        Class_data = np.mean(Class_data.T.values, axis = 0)
        ax.set_ylim([-0.2, 1])
        ax.grid(False)
        ax.invert_xaxis()
        ax.plot(x_axis, Class_data, color="black")
        plt.savefig("./spectrum/Class_{}.png".format(i), transparent=True, bbox_inches="tight", pad_inches=0.1)
        pd.DataFrame(Class_data).to_csv("./spectrum/Class_{}.csv".format(i))


def main():
    image_file_path, axis_path = ask_directory()
    PCA_analysis(image_file_path, axis_path)


if __name__ == '__main__':
    main()
