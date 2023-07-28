import urllib
import threading
import requests
import os
import logging

# Define the file name list
file_names = [
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp01.png',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp02.jpg',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp03.png',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp04.png',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp05.png',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp06.png',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp07.png',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp08.png',
    'group6/asserts/buildingSideIcons/20220222/buildingSideIcons_lyp09.png',
    'group6/asserts/buildingSideIcons/20220222/lyp10.png',
    'group6/asserts/buildingSideIcons/20220222/lyp11.png',
    'group6/asserts/buildingSideIcons/20220222/lyp12.png',
    'group6/asserts/buildingSideIcons/20220222/lyp13.jpg',
    'group6/asserts/buildingSideIcons/20220222/lyp14.jpg',
    'group6/asserts/buildingSideIcons/20220222/lyp15.png',
    'group6/asserts/buildingSideIcons/20220222/lyp16.png',
    'group6/asserts/buildingTopIcons/20220222/buildingTopIcons_lyp01.png',
    'group6/asserts/buildingTopIcons/20220222/buildingTopIcons_lyp02.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp01.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp02.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp03.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp04.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp05.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp06.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp07.png',
    'group6/asserts/lineIcons/20220222/lineIcons_lyp08.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp02.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp03.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp04.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp05.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp06.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp07.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp08.png',
    'group6/asserts/mapIcons/20220222/mapIcons_lyp09.png',
    'group6/asserts/polygonIcons/20220222/polygonIcons_lyp01.png',
    'group6/asserts/polygonIcons/20220222/polygonIcons_lyp02.png',
    'group6/asserts/polygonIcons/20220222/polygonIcons_lyp03.png',
    'group6/asserts/uvMap/20220222/uvMap_lyp01.png',
    'group6/asserts/uvMap/2023/icon_20230104165128111_387914.png',
    'group6/asserts/windowIcons/20220222/windowIcons_lyp01.jpg',
    'group6/asserts/windowIcons/20220222/windowIcons_lyp02.png',
    'group6/asserts/windowIcons/20220222/windowIcons_lyp03.png',
    'group6/asserts/windowIcons/20220222/windowIcons_lyp04.png',
    'background/systemIcons/bg01.jpg',
    'background/systemIcons/bg02.jpg',
    'buildingIcons/systemIcons/g_1_t_0.png',
    'buildingIcons/systemIcons/g_1_w_1.png',
    'buildingIcons/systemIcons/g_1_w_2.png',
    'buildingIcons/systemIcons/g_1_w_3.png',
    'buildingIcons/systemIcons/g_1_w_4.png',
    'buildingIcons/systemIcons/g_1_w_5.png',
    'buildingIcons/systemIcons/g_1_w_6.png',
    'buildingIcons/systemIcons/g_1_w_7.png',
    'buildingIcons/systemIcons/g_1_w_8.png',
    'buildingIcons/systemIcons/g_2_t_1.png',
    'buildingIcons/systemIcons/g_2_w_1.png',
    'ground/systemIcons/光1.png',
    'ground/systemIcons/光2.png',
    'ground/systemIcons/光3.png',
    'ground/systemIcons/光点黑白02.png',
    'ground/systemIcons/地板线01.png',
    'ground/systemIcons/地板面02.png',
    'lineIcons/3d/lightFlow_strip.png',
    'lineIcons/3d/lightFlow_strip02.png',
    'lineIcons/3d/lightFlow_strip03.jpg',
    'lineIcons/3d/lightFlow_strip04.png',
    'lineIcons/3d/lightFlow_strip05.png',
    'lineIcons/3d/light_line.png',
    'mapIcons/systemIcons/0_default.png',
    'mapIcons/systemIcons/10.png',
    'mapIcons/systemIcons/11.png',
    'mapIcons/systemIcons/12.png',
    'mapIcons/systemIcons/13.png',
    'mapIcons/systemIcons/15.png',
    'mapIcons/systemIcons/16.png',
    'mapIcons/systemIcons/17.png',
    'mapIcons/systemIcons/18.png',
    'mapIcons/systemIcons/19.png',
    'mapIcons/systemIcons/20.png',
    'mapIcons/systemIcons/22.png',
    'mapIcons/systemIcons/24.png',
    'mapIcons/systemIcons/25.png',
    'mapIcons/systemIcons/26.png',
    'mapIcons/systemIcons/27.png',
    'mapIcons/systemIcons/28.png',
    'mapIcons/systemIcons/29.png',
    'mapIcons/systemIcons/7.png',
    'mapIcons/systemIcons/8.png',
    'mapIcons/systemIcons/9.png',
    'mapIcons/systemIcons/circle.png',
    'mapIcons/systemIcons/mapIcons_1.png',
    'mapIcons/systemIcons/mapIcons_2.png',
    'mapIcons/systemIcons/mapIcons_3.png',
    'mapIcons/systemIcons/mapIcons_4.png',
    'mapIcons/systemIcons/mapIcons_5.png',
    'mapIcons/systemIcons/mapIcons_6.png',
    'normal/systemIcons/Water_1_M_Normal.jpg',
    'normal/systemIcons/Water_2_M_Normal.jpg',
    'normal/systemIcons/normal.jpg',
    'normal/systemIcons/waternormals.jpg',
    'polygonIcons/icon_20211122171934767_911124.png',
    'polygonIcons/icon_20211122171942873_602309.png',
    'polygonIcons/icon_20211122171947591_953861.png',
    'polygonIcons/systemIcons/polygonIcons_1.png',
    'polygonIcons/systemIcons/polygonIcons_2.png',
    'polygonIcons/systemIcons/polygonIcons_3.png',
    'polygonIcons/systemIcons/polygonIcons_4.png',
    'polygonIcons/systemIcons/polygonIcons_5.png',
    'polygonIcons/systemIcons/polygonIcons_6.jpg',
    'polygonIcons/systemIcons/reflection.jpg',
    'polygonIcons/systemIcons/refraction.jpg',
    'polygonIcons/systemIcons/water.jpg',
    'polygonIcons/systemIcons/water1.png',
    'polygonIcons/systemIcons/water2.png',
    'skybox/20191121193000290_223311/skybox_20191121193000290_223311_11111111.jpg',
    'skybox/20191216174521024_90430/skybox_20191216174521024_90430_11111111.jpg',
    'skybox/system/build/up.jpg',
    'skybox/systemIcons/reflection1.jpg',
    'skybox/systemIcons/reflection2.jpg',
    'skybox/systemIcons/reflection3.jpg',
    'uvMap/systemIcons/30.png',
    'uvMap/systemIcons/31.png',
    'uvMap/systemIcons/32.png',
    'uvMap/systemIcons/defaultAoMap.png',
    'uvMap/systemIcons/reflect1.jpg',
    'uvMap/systemIcons/scroll.jpg',
    'uvMap/systemIcons/uvMap20.png',
    'uvMap/systemIcons/uvMap71.png',
    'projectSkyBox/20200803183038354_253944/up.jpg',
    'projectSkyBox/20200803183038354_253944/rt.jpg',
    'projectSkyBox/20200803183038354_253944/lf.jpg',
    'projectSkyBox/20200803183038354_253944/fr.jpg',
    'projectSkyBox/20200803183038354_253944/dn.jpg',
    'projectSkyBox/20200803183038354_253944/bk.jpg',
    'projectSkyBox/20210625120128023_118135/up.jpg',
    'projectSkyBox/20210625120128023_118135/rt.jpg',
    'projectSkyBox/20210625120128023_118135/lf.jpg',
    'projectSkyBox/20210625120128023_118135/fr.jpg',
    'projectSkyBox/20210625120128023_118135/dn.jpg',
    'projectSkyBox/20210625120128023_118135/bk.jpg',
    'projectSkyBox/20210625120230547_536567/up.jpg',
    'projectSkyBox/20210625120230547_536567/rt.jpg',
    'projectSkyBox/20210625120230547_536567/lf.jpg',
    'projectSkyBox/20210625120230547_536567/fr.jpg',
    'projectSkyBox/20210625120230547_536567/dn.jpg',
    'projectSkyBox/20210625120230547_536567/bk.jpg',
    'projectSkyBox/20210625120244023_487788/up.jpg',
    'projectSkyBox/20210625120244023_487788/rt.jpg',
    'projectSkyBox/20210625120244023_487788/lf.jpg',
    'projectSkyBox/20210625120244023_487788/fr.jpg',
    'projectSkyBox/20210625120244023_487788/dn.jpg',
    'projectSkyBox/20210625120244023_487788/bk.jpg',
    'projectSkyBox/20210625120302548_592483/up.jpg',
    'projectSkyBox/20210625120302548_592483/rt.jpg',
    'projectSkyBox/20210625120302548_592483/lf.jpg',
    'projectSkyBox/20210625120302548_592483/fr.jpg',
    'projectSkyBox/20210625120302548_592483/dn.jpg',
    'projectSkyBox/20210625120302548_592483/bk.jpg',
    'projectSkyBox/systemIcons/skybox/up.jpg',
    'projectSkyBox/systemIcons/skybox/rt.jpg',
    'projectSkyBox/systemIcons/skybox/lf.jpg',
    'projectSkyBox/systemIcons/skybox/fr.jpg',
    'projectSkyBox/systemIcons/skybox/dn.jpg',
    'projectSkyBox/systemIcons/skybox/bk.jpg',
    'skybox/20191119161556671_609907/up.jpg',
    'skybox/20191119161556671_609907/rt.jpg',
    'skybox/20191119161556671_609907/lf.jpg',
    'skybox/20191119161556671_609907/fr.jpg',
    'skybox/20191119161556671_609907/dn.jpg',
    'skybox/20191119161556671_609907/bk.jpg',
    'skybox/systemIcons/reflection1/up.jpg',
    'skybox/systemIcons/reflection1/rt.jpg',
    'skybox/systemIcons/reflection1/lf.jpg',
    'skybox/systemIcons/reflection1/fr.jpg',
    'skybox/systemIcons/reflection1/dn.jpg',
    'skybox/systemIcons/reflection1/bk.jpg',
    'skybox/systemIcons/reflection2/up.jpg',
    'skybox/systemIcons/reflection2/rt.jpg',
    'skybox/systemIcons/reflection2/lf.jpg',
    'skybox/systemIcons/reflection2/fr.jpg',
    'skybox/systemIcons/reflection2/dn.jpg',
    'skybox/systemIcons/reflection2/bk.jpg',
    'skybox/systemIcons/reflection3/up.jpg',
    'skybox/systemIcons/reflection3/rt.jpg',
    'skybox/systemIcons/reflection3/lf.jpg',
    'skybox/systemIcons/reflection3/fr.jpg',
    'skybox/systemIcons/reflection3/dn.jpg',
    'skybox/systemIcons/reflection3/bk.jpg'
]

# Define the base URL for downloading the files
base_url = 'https://city.thingjs.com/ra/file/fetch/{}'

# Define the download function


def download(url, filename):
    # 判断文件是否存在
    if os.path.exists(filename):
        if os.path.getsize(filename) > 0:
            print(
                f'File {filename} already exists and is not empty. Skipping download.')
            return

    directory = os.path.dirname(filename)
    if not os.path.exists(directory):
        os.makedirs(directory)
    try:
        response = requests.get(url)
        response.raise_for_status()
        with open(filename, 'wb') as f:
            f.write(response.content)
        print(f'Downloaded file {filename}')
    except requests.exceptions.RequestException as e:
        log_file = os.path.join(os.getcwd(), 'errorO森城市的贴图们.log')
        logging.basicConfig(
            filename=log_file, level=logging.ERROR, format='%(asctime)s %(message)s')
        logging.error(f'Failed to download file {url}: {e}')


# Create a thread for each file name
threads = []
for index, filename in enumerate(file_names):
    url = base_url.format(filename, filename)
    thread = threading.Thread(
        target=download, args=(url, f'./森城市的贴图们/{filename}'))
    # thread = threading.Thread(target=download, args=(url, f'./ico/{filename}/{filename}.png'))
    threads.append(thread)
    thread.start()

# Wait for all threads to finish
for thread in threads:
    thread.join()
