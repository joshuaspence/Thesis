#------------------------------------------------------------------------------#
#                                                                              #
#                                CONFIGURATION                                 #
#                                                                              #
#------------------------------------------------------------------------------#
TARGETS     := tex
TITLE       := SOURCE CODE

tex_TITLE   := source code transcriptions
tex_TARGETS := c.tex \
               matlab.tex

#------------------------------------------------------------------------------#
#                                                                              #
#                          ADDITIONAL DEPENDENCIES                             #
#                                                                              #
#------------------------------------------------------------------------------#
tex/c.tex:      source/top_n_outlier_pruning_block.c
tex/matlab.tex: source/TopN_Outlier_Pruning_Block_MATLAB_SORTED.m \
                source/TopN_Outlier_Pruning_Block_MATLAB_SORTED_INLINE.m \
                source/TopN_Outlier_Pruning_Block_MATLAB_UNSORTED.m \
                source/TopN_Outlier_Pruning_Block_MATLAB_UNSORTED_INLINE.m