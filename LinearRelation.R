library(rJava)
library(xlsx)
library(ggplot2)
library(ggrepel)

data.activity <- read.xlsx(file = "C:/Users/DELL/OneDrive\ -\ Nanyang\ Technological\ University/Works/WangYong/Manuscript/FeNi_Alloys_OER.xlsx",
          sheetIndex = 4, header = TRUE, rowIndex = c(1:6))

Figure6 <- ggplot(data = na.omit(data.activity),
                  mapping = aes(x = dBandCenter.dn, y = Overpotential.OER))+
  geom_point(size=3, color=c("#FF80FF","blue", "#3BC371","#F14040"))+
  theme_bw(base_line_size = 1)+
  theme(axis.title = element_text(size=18), axis.text = element_text(size=16, color="black"),
        panel.border = element_rect(color="black", size=1.5))+
  labs(x=expression(paste("Spin down ", italic(epsilon)[italic("d")]," of active site for *OH (eV)")),
       y=paste("Calculated overpotential (V)"))+
  # geom_text(aes(label=Sample))+
  # geom_text(labels=c("Ni(111)", expression(paste("Fe"[0.25],"Ni"[0.75])),
  #   expression(paste("Fe"[0.5],"Ni"[0.5])), expression(paste("Fe"[0.75],"Ni"[0.25])))
  #   )
  geom_smooth(method = "lm", formula = y ~ x, se = F, color="black", size=1,linetype="dashed")+
  ggpmisc::stat_poly_eq(formula = y~x, parse = TRUE,
                        aes(label=paste(stat(eq.label),stat(rr.label), sep = "*\", \"*")),
                        label.x = 0.8, label.y = 0.7, coef.digits=2)+
  # geom_text_repel(aes(label = Sample), direction = "y") #, hjust=-0.3, vjust=0.9)+
  scale_x_continuous(limits = c(-1.35,0), breaks = seq(-1.5,0,by=0.3))+
  scale_y_continuous(limits = c(0.6,1.9), breaks = seq(0.65,1.95,by=0.3))

ggsave(filename = "./Fig6.pdf", plot = Figure6, device = "pdf",
       width = 5.5, height = 5, units = "in")
ggsave(filename = "./Fig6.png", plot = Figure6, device = "png",
       dpi = 900, width = 5.5, height = 5, units = "in")

data.activity$Overpotential.exprm <- c(0.44, 0.349,0.219,0.315,0.491)
volcano <- ggplot(data = data.activity, aes(x = x.Fe, y = Overpotential.OER))+
  geom_point(size=3, color = c("#FF80FF","blue", "#3BC371","#F14040", "black"))+
  # geom_smooth(method = "lm", formula = y ~ x + I((x - 0.5)*(x > 0.5)), se = F,
  #             color="black", size=1,linetype="solid")+
  geom_point(aes(x = x.Fe, y = Overpotential.exprm), shape = 24, size = 3.5,
             fill = c("#FF80FF","blue", "#3BC371","#F14040", "black"))+
  geom_smooth(aes(x = x.Fe, y = Overpotential.exprm), method = "lm",
              formula = y ~ x + I((x - 0.5)*(x > 0.5)), se = F, color="black",
              size=1,linetype="dashed")+
  geom_point(aes(x=0.5,y=0.286),shape = 24, size = 3.5, fill = "#3BC371")+
  # ggthemes::theme_base()+
  # ggthemes::theme_wsj()+
  theme_bw(base_line_size = 1)+
  theme(axis.title = element_text(size=18), axis.text = element_text(size=16, color="black"),
        panel.border = element_rect(color="black", size=1.5))+
  labs(x=expression(paste("Fe composition (", italic(x),")")),
       y=expression(paste("OER overpotential (V)"))
       )+
  scale_x_continuous(limits = c(0,1), breaks = seq(0,1,by=0.25))+
  scale_y_reverse(limits = c(1.9,0.05), breaks = seq(2.15,0.05,by=-0.3))

ggsave(filename = "./Fig6f.png", plot = volcano, device = "png",
       dpi = 900, width = 5.5, height = 5, units = "in")

##-----------------------d-band center----------------------------
data.dband <- read.xlsx(file = "C:/Users/DELL/OneDrive\ -\ Nanyang\ Technological\ University/Works/WangYong/Manuscript/FeNi_Alloys_OER.xlsx",
                           sheetIndex = 7, header = TRUE, rowIndex = c(1:7))
dband.bulk <- ggplot(data = data.dband[-5,], mapping = aes(x = x.Fe, y = ed.dn.bulk))+
  geom_point(shape=22, size=3, fill=c("#FF80FF","blue", "#3BC371","#F14040","black"))+
  geom_smooth(method = "lm", se = F, color="black", size=1, linetype="dashed")+
  ggpmisc::stat_poly_eq(formula = y~x, parse = TRUE,
                        aes(label=paste(stat(eq.label),stat(rr.label), sep = "*\", \"*")),
                        label.x = 0.3, label.y = 0.8, coef.digits=3)+
  
  geom_point(aes(x = x.Fe, y = ed.up.bulk),
             shape=24, size=3, fill=c("#FF80FF","blue", "#3BC371","#F14040","black"))+
  geom_smooth(aes(x = x.Fe, y = ed.up.bulk),
              method = "lm", se = F, color="black", size=1, linetype="dotted")+

  geom_point(aes(x = x.Fe, y = ed.av.bulk),
             shape=21, size=3, fill=c("#FF80FF","blue", "#3BC371","#F14040","black"))+
  geom_smooth(aes(x = x.Fe, y = ed.av.bulk),
              method = "lm", se = F, color="black", size=1, linetype="solid")+
  
  theme_bw(base_line_size = 1)+
  scale_x_continuous(limits = c(0,1), breaks = seq(0,1,by=0.25))+
  scale_y_continuous(limits = c(-2.2,0.8), breaks = seq(-2.0,0.8,by=0.4))+
  theme(axis.title = element_text(size=18), axis.text = element_text(size=16, color="black"),
        panel.border = element_rect(color="black", size=1.5))+
  labs(x=expression(paste("Fe composition (", italic(x), ")")),
       y=paste("d-band center (eV)"))

dband.surf <- ggplot(data = data.dband[-5,], mapping = aes(x = x.Fe, y = ed.dn.surf))+
  geom_point(shape=22, size=3, fill=c("#FF80FF","blue", "#3BC371","#F14040","black"))+
  geom_smooth(method = "lm", se = F, color="black", size=1, linetype="dashed")+
  ggpmisc::stat_poly_eq(formula = y~x, parse = TRUE,
                        aes(label=paste(stat(eq.label),stat(rr.label), sep = "*\", \"*")),
                        label.x = 0.3, label.y = 0.8, coef.digits=3)+
  
  geom_point(aes(x = x.Fe, y = ed.up.surf),
             shape=24, size=3, fill=c("#FF80FF","blue", "#3BC371","#F14040","black"))+
  geom_smooth(aes(x = x.Fe, y = ed.up.surf),
              method = "lm", se = F, color="black", size=1, linetype="dotted")+
  
  geom_point(aes(x = x.Fe, y = ed.av.surf),
             shape=21, size=3, fill=c("#FF80FF","blue", "#3BC371","#F14040","black"))+
  geom_smooth(aes(x = x.Fe, y = ed.av.surf),
              method = "lm", se = F, color="black", size=1, linetype="solid")+
  
  theme_bw(base_line_size = 1)+
  scale_x_continuous(limits = c(0,1), breaks = seq(0,1,by=0.25))+
  scale_y_continuous(limits = c(-2.2,0.8), breaks = seq(-2.0,0.8,by=0.4))+
  theme(axis.title = element_text(size=18), axis.text = element_text(size=16, color="black"),
        panel.border = element_rect(color="black", size=1.5))+
  labs(x=expression(paste("Fe composition (", italic(x), ")")),
       y=paste("d-band center (eV)"))

ggsave(filename = "./FigSI_linear_dband_bulk.png", plot = dband.bulk, device = "png",
       dpi = 900, width = 5.5, height = 5, units = "in")
ggsave(filename = "./FigSI_linear_dband_surf.png", plot = dband.surf, device = "png",
       dpi = 900, width = 5.5, height = 5, units = "in")


##-----------------------1/16 ML O adsorption free energy-----------------------
data.dGO <- read.xlsx(file = "C:/Users/DELL/OneDrive\ -\ Nanyang\ Technological\ University/Works/WangYong/Manuscript/FeNi_Alloys_OER.xlsx",
                           sheetIndex = 6, header = TRUE, colIndex = c(2,3,4,7))
data.dGO$Alloy <- factor(data.dGO$Alloy, levels = c("Fe0.25Ni0.75", "Fe0.5Ni0.5", "Fe0.75Ni0.25"))
data.dGO$Site <- factor(data.dGO$Site)

dGO.dis <- ggplot(data = data.dGO, aes(x=Site, y=`ΔG.O`))+
  geom_boxplot(aes(fill=Alloy), outlier.shape=23, outlier.size=2.5)+
  theme_bw(base_line_size = 1)+
  theme(axis.title = element_text(size=14),
        axis.text = element_text(size=12, color="black"),
        panel.border = element_rect(color="black", size=1))+
  facet_grid(. ~ Alloy)+
             # labeller = label_parsed(labels = c(expression(paste("Fe"[0.25], "Ni"[0.75])),
             #                                  expression(paste("Fe"[0.5], "Ni"[0.5])),
             #                                  expression(paste("Fe"[0.75], "Ni"[0.25]))
             #                                  )
             #                         )
             # )+
  labs(x=expression(paste("Fe"["x"], "Ni"["(1-x)"])),
       y= expression(paste(Delta, italic("G")["*O"], " (eV)"))
       )+
    
  scale_fill_manual(values = c(RColorBrewer::brewer.pal(7, "Blues")[5], "#3BC371","#F14040"))+
  scale_y_continuous(breaks = seq(-0.6,2.4,by=0.3))+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=0.3)+
  # geom_point()+
  # scale_shape_manual(values = c(1, 21))+
  guides(Site='none', fill="none")+
  geom_hline(yintercept=0.13, size=0.8, linetype = "dashed", color="#FF80FF")

ggsave(filename = "./FigSI_dGO_distribution.png", plot = dGO.dis, device = "png",
       dpi = 900, width = 8, height = 6, units = "in")
