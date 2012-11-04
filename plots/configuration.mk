#------------------------------------------------------------------------------#
#                                                                              #
#                                CONFIGURATION                                 #
#                                                                              #
#------------------------------------------------------------------------------#
TARGETS            := block_size c matlab
TITLE              := PLOTS

block_size_TITLE   := block size profiling plots
block_size_TARGETS := distance_calls.tex \
                      function_execution_time.tex \
                      function_run_time_complexity.lin.tex \
                      function_run_time_complexity.log.tex \
                      legend.tex \
                      total_execution_time.tex \
                      total_run_time_complexity.lin.tex \
                      total_run_time_complexity.log.tex \
                      vectors_pruned.tex

c_TITLE            := C profiling plots
c_TARGETS          := $(foreach DATASET,$(DATASETS),$(addsuffix .tex,$(DATASET))) \
                      all_datasets.tex \
                      legend.tex

matlab_TITLE       := MATLAB profiling plots
matlab_TARGETS     := $(foreach DATASET,$(DATASETS),$(addsuffix .tex,$(DATASET))) \
                      all_datasets.tex \
                      legend.tex

#------------------------------------------------------------------------------#
#                                                                              #
#                          ADDITIONAL DEPENDENCIES                             #
#                                                                              #
#------------------------------------------------------------------------------#