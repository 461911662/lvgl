############################################################################
# apps/graphics/lvgl/Makefile
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
############################################################################

include $(APPDIR)/Make.defs

# LVGL graphic library

LVGL_DIR = .
LVGL_DIR_NAME = lvgl
LVGL_PATH ?= ${shell pwd}

-include $(LVGL_DIR)/lvgl.mk

ifneq ($(CONFIG_LV_ASSERT_HANDLER_INCLUDE), "")
CFLAGS += "-DLV_ASSERT_HANDLER=ASSERT(0);"
endif

ifeq ($(and $(CONFIG_LV_USE_PERF_MONITOR),$(CONFIG_SCHED_CPULOAD)),y)
CFLAGS += "-DLV_SYSMON_GET_IDLE=lv_nuttx_get_idle"
endif

ifeq ($(and $(CONFIG_SCHED_INSTRUMENTATION),$(CONFIG_LV_USE_PROFILER)),y)
CFLAGS += "-DLV_PROFILER_BEGIN=sched_note_beginex(NOTE_TAG_GRAPHICS, __func__)"
CFLAGS += "-DLV_PROFILER_END=sched_note_endex(NOTE_TAG_GRAPHICS, __func__)"

CFLAGS += "-DLV_PROFILER_BEGIN_TAG(str)=sched_note_beginex(NOTE_TAG_GRAPHICS, str)"
CFLAGS += "-DLV_PROFILER_END_TAG(str)=sched_note_endex(NOTE_TAG_GRAPHICS, str)"
endif

ifneq ($(CONFIG_LV_OPTLEVEL), "")
# Since multiple options need to be supported, subst needs to be used here to remove
# the redundant double quotes, otherwise it will cause command parsing errors.
CFLAGS   += $(subst ",, $(CONFIG_LV_OPTLEVEL))
CXXFLAGS += $(subst ",, $(CONFIG_LV_OPTLEVEL))
endif

ifneq ($(wildcard $(LVGL_DIR)/.git),)

include $(APPDIR)/Application.mk

SUOBJS :=
ifneq ($(EXTRA),)
$(eval $(call SPLITVARIABLE,OBJS_SPILT,$(SORTOBJS),100))
$(foreach BATCH, $(OBJS_SPILT_TOTAL), \
	$(foreach obj, $(OBJS_SPILT_$(BATCH)), \
		$(foreach EXT, $(EXTRA), \
			$(eval substitute := $(patsubst %$(SUFFIX)$(OBJEXT),%$(SUFFIX)$(EXT),$(obj))) \
			$(eval SUOBJS += $(substitute)) \
		) \
	) \
)
endif

clean::
	$(eval $(call SPLITVARIABLE,SUOBJS_SPILT,$(SUOBJS),100))
	$(foreach BATCH, $(SUOBJS_SPILT_TOTAL), \
		$(foreach obj, $(SUOBJS_SPILT_$(BATCH)), \
			$(shell rm -rf $(obj)) \
		) \
	)

distclean::

endif
