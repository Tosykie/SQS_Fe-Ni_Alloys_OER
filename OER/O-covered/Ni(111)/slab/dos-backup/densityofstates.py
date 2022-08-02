'''
Zhihao Zeng
Dec. 24 2021
'''
import os
import numpy as np
from scipy import integrate
# import matplotlib.pyplot as plt
# from matplotlib.collections import LineCollection
# from matplotlib.gridspec import GridSpec

from pymatgen.io.vasp.outputs import Vasprun
from pymatgen.electronic_structure.core import Spin, OrbitalType, Orbital
# from pymatgen.electronic_structure import plotter
from pymatgen.electronic_structure.plotter import DosPlotter  # , BSDOSPlotter, BSPlotter, BSPlotterProjected
from pymatgen.electronic_structure.dos import add_densities
from pymatgen.util.plotting import pretty_plot
from matplotlib import rcParams
from matplotlib.ticker import AutoMinorLocator, MultipleLocator, FuncFormatter

rcParams['font.family'] = "Arial"

class ReadVasprun:
    def __init__(self, xml_path):
        self.xml_path = xml_path

    def get_element_and_atom_numbers(self):
        elements_nums = list()
        with open(os.path.join(self.xml_path, 'vasprun.xml'), 'r') as fvasprun:
            while True:
                line = fvasprun.readline()
                if not line:
                    break
                if 'PAW_PBE' in line:
                    matched = line.strip().split()[1]
                    num, element = [i for i in matched.split('</c><c>') if i != '']
                    elements_nums.append([element, int(num)])
        return elements_nums

    def get_ele_num(self, species, num):
        elements_nums = self.get_element_and_atom_numbers()
        ind = [i for i in range(len(elements_nums)) if elements_nums[i][0] == species][0]
        if elements_nums[ind][1] == 1:
            return ''
        ele_num = num - sum([n[1] for n in elements_nums[:ind]])
        return ele_num


class DosPlot(DosPlotter):
    def __init__(self):
        super().__init__()

    def get_plot(self, xlim=None, ylim=None, length=15, hight=10, line_width=3, grid_line_width=2):
        ncolors = max(3, len(self._doses))
        ncolors = min(9, ncolors)

        import palettable

        # pylint: disable=E1101
        colors = palettable.colorbrewer.qualitative.Set1_9.mpl_colors
        colors = colors[1:]

        y = None
        alldensities = []
        allenergies = []
        plt = pretty_plot(length, hight)

        # Note that this complicated processing of energies is to allow for
        # stacked plots in matplotlib.
        for key, dos in self._doses.items():
            energies = dos["energies"]
            densities = dos["densities"]
            if not y:
                y = {
                    Spin.up: np.zeros(energies.shape),
                    Spin.down: np.zeros(energies.shape),
                }
            newdens = {}
            for spin in [Spin.up, Spin.down]:
                if spin in densities:
                    if self.stack:
                        y[spin] += densities[spin]
                        newdens[spin] = y[spin].copy()
                    else:
                        newdens[spin] = densities[spin]
            allenergies.append(energies)
            alldensities.append(newdens)

        keys = list(self._doses.keys())
        keys.reverse()
        alldensities.reverse()
        allenergies.reverse()
        allpts = []
        for i, key in enumerate(keys):
            x = []
            y = []
            for spin in [Spin.up, Spin.down]:
                if spin in alldensities[i]:
                    densities = list(int(spin) * alldensities[i][spin])
                    energies = list(allenergies[i])
                    if spin == Spin.down:
                        energies.reverse()
                        densities.reverse()
                    x.extend(energies)
                    y.extend(densities)
            allpts.extend(list(zip(x, y)))
            if self.stack:
                plt.fill(x, y, color=colors[i % ncolors], label=str(key))
            else:
                plt.plot(x, y, color=colors[i % ncolors], label=str(key), linewidth=line_width)
            if not self.zero_at_efermi:
                ylim = plt.ylim()
                plt.plot(
                    [self._doses[key]["efermi"], self._doses[key]["efermi"]],
                    ylim,
                    color=colors[i % ncolors],
                    linestyle="--",
                    linewidth=2,
                )

        if xlim:
            plt.xlim(xlim)
        if ylim:
            plt.ylim(ylim)
        else:
            xlim = plt.xlim()
            relevanty = [p[1] for p in allpts if xlim[0] < p[0] < xlim[1]]
            plt.ylim((min(relevanty), max(relevanty)))

        if self.zero_at_efermi:
            ylim = plt.ylim()
            plt.plot([0, 0], ylim, "k--", linewidth=grid_line_width)

        plt.xlabel("Energies (eV)")
        plt.ylabel("Density of states")

#        plt.axhline(y=0, color="k", linestyle="--", linewidth=grid_line_width)
        plt.axhline(y=0, color="k", linestyle="-", linewidth=grid_line_width)
        plt.legend()
        leg = plt.gca().get_legend()
        ltext = leg.get_texts()  # all the text.Text instance in the legend
        plt.setp(ltext, fontsize=30)
        plt.tight_layout()
        return plt


class DensityOfStates(ReadVasprun):
    def __init__(self, xml_path):
        self.xml_path = xml_path
        self.dos_vasprun = Vasprun(os.path.join(self.xml_path, 'vasprun.xml'))
        self.cdos = self.obtain_complete_dos()
        self.strcture = self.dos_vasprun.final_structure
        super().__init__(self.xml_path)

    def obtain_complete_dos(self):
        cdos = self.dos_vasprun.complete_dos
        return cdos

    def obtain_elements_dos(self, *elements):
        element_dos = self.cdos.get_element_dos()
        if elements:
            ele_dos = {}
            for element in elements:
                ele_dos[element] = element_dos[element]
            return ele_dos
        return element_dos

    def obtain_elements_spdf_dos(self, **elements_spdf):
        '''example -->  elements_spdf={'H':'s', 'C':['s', 'p']}'''
        element_spd_dos = dict()
        for element, densities in elements_spdf.items():
            spdf_dos = self.cdos.get_element_spd_dos(element)
            for density in densities:
                if density == 's':
                    element_spd_dos[element + r'$_{\rm s}$'] = spdf_dos[OrbitalType.s]
                elif density == 'p':
                    element_spd_dos[element + r'$_{\rm p}$'] = spdf_dos[OrbitalType.p]
                elif density == 'd':
                    element_spd_dos[element + r'$_{\rm d}$'] = spdf_dos[OrbitalType.d]
                elif density == 'f':
                    element_spd_dos[element + r'$_{\rm f}$'] = spdf_dos[OrbitalType.f]
        return element_spd_dos

    def obtain_element_orbital_dos(self):
        pass

    def obtain_site_dos(self, *atomic_num):
        site_dos = dict()
        for num in atomic_num:
            site = self.strcture[num - 1]
            element = str(site.specie)
            ele_num = self.get_ele_num(element, int(num))
            dos_data = self.cdos.get_site_dos(site)
            site_dos[element + str(ele_num)] = dos_data
        return site_dos

    def obtain_site_spdf_dos(self, **sites_spdf):
        '''example ---> sites_spdf={'1': [‘s’, ’p‘], '3': [’d‘]}'''
        sites_spd_dos = dict()
        for num, spdf in sites_spdf.items():
            site = self.strcture[int(num) - 1]
            spd_dos = self.cdos.get_site_spd_dos(site)
            element = str(site.specie)
            ele_num = self.get_ele_num(element, int(num))
            for density in spdf:
                if density == 's':
                    sites_spd_dos[element + str(ele_num) + r'$_{\rm s}$'] = spd_dos[OrbitalType.s]
                elif density == 'p':
                    sites_spd_dos[element + str(ele_num) + r'$_{\rm p}$'] = spd_dos[OrbitalType.p]
                elif density == 'd':
                    sites_spd_dos[element + str(ele_num) + r'$_{\rm d}$'] = spd_dos[OrbitalType.d]
                elif density == 'f':
                    sites_spd_dos[element + str(ele_num) + r'$_{\rm f}$'] = spd_dos[OrbitalType.f]
        return sites_spd_dos

    def obtain_site_orbital_dos(self, **sites_orbits):
        '''example ---> sites_orbits={'1': [‘px’, ‘py’, ‘pz’], '3': [‘dxy’, ‘dyz’]}'''
        orbital_dos = dict()
        for num, orbits in sites_orbits.items():
            site = self.strcture[int(num) - 1]
            element = str(site.specie)
            ele_num = self.get_ele_num(element, int(num))
            for orbit in orbits:
                if orbit == 's':
                    orbital_dos[element + str(ele_num) + r'$_{\rm s}$'] = self.cdos.get_site_orbital_dos(site, Orbital.s)
                elif orbit == 'px':
                    orbital_dos[element + str(ele_num) + r'$_{\rm p_x}$'] = self.cdos.get_site_orbital_dos(site, Orbital.px)
                elif orbit == 'py':
                    orbital_dos[element + str(ele_num) + r'$_{\rm p_y}$'] = self.cdos.get_site_orbital_dos(site, Orbital.py)
                elif orbit == 'pz':
                    orbital_dos[element + str(ele_num) + r'$_{\rm p_z}$'] = self.cdos.get_site_orbital_dos(site, Orbital.pz)
                elif orbit == 'dxy':
                    orbital_dos[element + str(ele_num) + r'$_{\rm d_{xy}}$'] = self.cdos.get_site_orbital_dos(site, Orbital.dxy)
                elif orbit == 'dyz':
                    orbital_dos[element + str(ele_num) + r'$_{\rm d_{yz}}$'] = self.cdos.get_site_orbital_dos(site, Orbital.dyz)
                elif orbit == 'dz2':
                    orbital_dos[element + str(ele_num) + r'$_{\rm d_{z^2}}$'] = self.cdos.get_site_orbital_dos(site, Orbital.dz2)
                elif orbit == 'dxz':
                    orbital_dos[element + str(ele_num) + r'$_{\rm d_{xz}}$'] = self.cdos.get_site_orbital_dos(site, Orbital.dxz)
                elif orbit == 'dx2' or orbit == 'dx2-y2':
                    orbital_dos[element + str(ele_num) + r'$_{\rm d_{x^2-y^2}}$'] = self.cdos.get_site_orbital_dos(site, Orbital.dx2)
                elif orbit == 'f_3':
                    orbital_dos[element + str(ele_num) + r'$_{\rm f\_3}$'] = self.cdos.get_site_orbital_dos(site, Orbital.f_3)
                elif orbit == 'f_2':
                    orbital_dos[element + str(ele_num) + r'$_{\rm f\_2}$'] = self.cdos.get_site_orbital_dos(site, Orbital.f_2)
                elif orbit == 'f_1':
                    orbital_dos[element + str(ele_num) + r'$_{\rm f\_1}$'] = self.cdos.get_site_orbital_dos(site, Orbital.f_1)
                elif orbit == 'f0':
                    orbital_dos[element + str(ele_num) + r'$_{\rm f0}$'] = self.cdos.get_site_orbital_dos(site, Orbital.f0)
                elif orbit == 'f1':
                    orbital_dos[element + str(ele_num) + r'$_{\rm f1}$'] = self.cdos.get_site_orbital_dos(site, Orbital.f1)
                elif orbit == 'f2':
                    orbital_dos[element + str(ele_num) + r'$_{\rm f2}$'] = self.cdos.get_site_orbital_dos(site, Orbital.f2)
                elif orbit == 'f3':
                    orbital_dos[element + str(ele_num) + r'$_{\rm f3}$'] = self.cdos.get_site_orbital_dos(site, Orbital.f3)
                else:
                    raise Exception(f'no such orbit：{orbit}')
        return orbital_dos

    def generate_dos_dict(self, *args, **kwargs):
        dos_data = DosPlot()
        if 'plot_cdos' in args:
            dos_data.add_dos('Total DOS', self.cdos)
        if 'plot_element_dos' in args:
            if 'element_dos' in kwargs:
                plot_element_dos = self.obtain_elements_dos(*kwargs['element_dos'])
            else:
                plot_element_dos = self.obtain_elements_dos()
            dos_data.add_dos_dict(plot_element_dos)
        if 'elements_spdf' in kwargs:
            element_spd_dos = self.obtain_elements_spdf_dos(**kwargs['elements_spdf'])
            dos_data.add_dos_dict(element_spd_dos)
        if 'sites_dos' in kwargs:
            sitesdos = self.obtain_site_dos(*kwargs['sites_dos'])
            dos_data.add_dos_dict(sitesdos)
        if 'sites_spdf' in kwargs:
            sites_spdf_dos = self.obtain_site_spdf_dos(**kwargs['sites_spdf'])
            dos_data.add_dos_dict(sites_spdf_dos)
        if 'sites_orbits' in kwargs:
            sites_orbits_dos = self.obtain_site_orbital_dos(**kwargs['sites_orbits'])
            dos_data.add_dos_dict(sites_orbits_dos)
        return dos_data

    def dos_poltter(self, plotDOS, fig="dos", font="Times New Roman", xlim=None, ylim=None, rm_x_scale=False, rm_y_scale=False):
        pltdos = plotDOS.get_plot(xlim=xlim, ylim=ylim, line_width=6, grid_line_width=3)
#        rcParams['lines.linewidth'] = 8
#        rcParams['axes.linewidth'] = 2
#        rcParams['font.family'] = font
        # rcParams['font.weight'] = 'bold'
#        pltdos.xlabel(xlabel=r'E'+u"\u2212"+r'E$_{\rm f}$ (eV)')
        pltdos.xlabel(xlabel=r'E-E$_{\rm f}$ (eV)')
        pltdos.ylabel(ylabel="PDOS (states/eV)")
        pltdos.tick_params(axis='both', direction='out', length=12, width=2)
        pltdos.legend(prop={'size': 50, 'weight': 'normal'}, loc='upper right')
        # pltdos.axis('off')

        # pltdos.tick_params(axis='both', direction='out', length=8.0, width=4, labelsize=38, )
        if rm_x_scale:
            pltdos.xticks([])
        if rm_y_scale:
            pltdos.yticks([])
        ax = pltdos.gca()
        line_width = 3
        # ax.spines['bottom'].set_visible(False)
        # ax.spines['left'].set_visible(False)
        # ax.spines['top'].set_visible(False)
        # ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_linewidth(line_width)
        ax.spines['left'].set_linewidth(line_width)
        ax.spines['top'].set_linewidth(line_width)
        ax.spines['right'].set_linewidth(line_width)
        # plt1.show()

        # https://blog.csdn.net/qq_32454557/article/details/116986506
#        ax.set_xlabel(r'E'+u"\u2212"+r'E$_{\rm f}$ (eV)', {'weight': 'normal', 'size': 38})
        ax.set_xlabel(r'E-E$_{\rm f}$ (eV)', {'weight': 'normal', 'size': 38})
        ax.set_ylabel("PDOS (states/eV)", {'weight': 'normal', 'size': 38})
#        labels = ax.get_xticklabels() + ax.get_yticklabels()
#        [label.set_fontweight('bold') for label in labels]

        # x_major_location = MultipleLocator(5)
        # ax.xaxis.set_major_locator(x_major_location)
        # y_major_location = MultipleLocator(5)
        # ax.yaxis.set_major_locator(y_major_location)
        pltdos.savefig(self.xml_path + r"\{}.png".format(fig), format='png', dpi=300, transparent=True)
        pltdos.close()

    @staticmethod
    def cal_band_center(energies, densities):
        centers_dict = {}
        for spin, density in densities.items():
            energies = np.array(energies)
            density = np.array(density)
            energy_multiply_density = energies * density
            center = integrate.trapz(energy_multiply_density, energies) / integrate.trapz(density, energies)
            centers_dict[spin] = center
        return centers_dict

    def output_band_centers(self, dos_dict, file_name='band_centers'):
        data = dos_dict.get_dos_dict()
        with open(os.path.join(self.xml_path, file_name), 'w') as file:
            title = 'density\t\t\tspin_up(eV)\t\t\tspin_down(eV)\t\t\taverage(eV)\n'
            file.write(title)
            for orbital_type, dens in data.items():
                energies = dens['energies']
                densities = dens['densities']
                # efermi = dens['efermi']
                centers_dict = DensityOfStates.cal_band_center(energies, densities)
                if len(centers_dict) == 1:
                    orbital_type += '\t                 \t                 \t{}\n'.format(centers_dict['1'])
                else:
                    average = (centers_dict['1'] + centers_dict['-1']) / 2
                    # TODO: 总的态密度是不是等于两个自旋的态相加？
                    orbital_type += '\t\t{}\t\t{}\t\t{}\n'.format(centers_dict['1'], centers_dict['-1'], average)
                file.write(orbital_type)

    def output_dos_data(self, dos_data, filename='dos.dat'):
        pass

    def main(self, base_path):
        '''paths_lib = find_paths.find_paths(base_path)
        for path in paths_lib:
            if find_paths.whether_dos_simulation(path) and find_paths.whether_simulation_complete(path):
                self.generate_dos_dict(plot_element_dos=True, plot_cdos=True)'''
        pass

    def main_single_path(self):
        # self.generate_dos_dict(plot_cdos=True, plot_element_dos=True)
        pass
    
#    def SumDOS(self, sites: list):
#        cdos = self.cdos
#        strc = self.strcture
#        sumdos = cdos.get_site_orbital_dos(strc[sites[0]-1], OrbitalType.d)
#        for site in sites[1:]:
#            sumdos = add_densities(sumdos, cdos.get_site_orbital_dos(strc[site-1], OrbitalType.d))
#        return sumdos


if __name__ == '__main__':
    path = r"."
    dos = DensityOfStates(path)
#    dosdata = dos.generate_dos_dict(sites_spdf={'6': ['d'], '22':['d'], '65':['p']})
    dosdata = dos.generate_dos_dict(elements_spdf={'O':'p','Ni':'d'})
#    dos.output_band_centers(dosdata, file_name='band_centers.dat')  # 计算每一条态密度的中心
#    dosdata = dos.generate_dos_dict(elements_spdf={'Ni':'d'})
#    surfaceFe = dos.SumDOS(list(range(37,45)))
#    dosdata.add_dos_dict(surfaceFe)
    dos.dos_poltter(dosdata, fig='dos', font='Arial', xlim=[-8, 6])  # 输出态密度图像
