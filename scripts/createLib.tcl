set PDK_ROOT    "/opt/synopsys/saed/32-edk"
set TECH_FILE   "$PDK_ROOT/tech/tf/saed32nm_1p9m.tf"
set STARRC_PATH "$PDK_ROOT/tech/starrc"
set TLUPLUS_MAX "$STARRC_PATH/max/saed32nm_1p9m_Cmax.tluplus"
set TLUPLUS_MIN "$STARRC_PATH/min/saed32nm_1p9m_Cmin.tluplus"
set MAP_FILE    "$STARRC_PATH/saed32nm_tf_itf_tluplus.map"

# Bibliotecas de Referência 
# RVT    - Reference Vt
# PG     - Power & Ground
# Frame  - Only black box
# Timing - Information
set REF_LIBS    [list "$PDK_ROOT/lib/stdcell_rvt/ndm/saed32rvt_pg_frame_timing.ndm"\
                      "$PDK_ROOT/lib/stdcell_rvt/ndm/saed32rvt_base_frame_timing.ndm"]

if {[file exists work_lib.ndm]} { 
    file delete -force work_lib.ndm 
}

create_lib saed32_rvt \
    -technology $TECH_FILE \
    -ref_libs   $REF_LIBS

read_parasitic_tech -tlup $TLUPLUS_MAX -layermap $MAP_FILE -name tlup_max
read_parasitic_tech -tlup $TLUPLUS_MIN -layermap $MAP_FILE -name tlup_min
