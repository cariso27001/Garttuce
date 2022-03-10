module AoB

using Cropbox
using ..Garlic
using TimeZones

ND = @config (
    :Calendar => (
        :init => ZonedDateTime(2007, 9, 1, tz"Asia/Seoul"),
        :last => ZonedDateTime(2008, 8, 31, tz"Asia/Seoul"),
    ),
    :Weather => (:store => Garlic.loadwea(Garlic.datapath("2007.wea"), tz"Asia/Seoul")),
    :Phenology => (:planting_date => ZonedDateTime(2007, 11, 1, tz"Asia/Seoul")),
)

tz = tz"America/Los_Angeles"

KMSP = @config (
# # CV PHYL ILN GLN LL LER SG SD LTAR LTARa LIR Topt Tceil critPPD
# KM1 134 4 10 65.0 4.70 1.84 122 0 0.4421 0.1003 22.28 34.23 12
    :Phenology => (
        optimal_temperature = 22.28, # Topt
        ceiling_temperature = 34.23, # Tceil
        critical_photoperiod = 12, # critPPD
        #initial_leaves_at_harvest = , # ILN
        maximum_leaf_initiation_rate = 0.1003, # LIR
        # storage_days = 100, # SD
        storage_temperature = 5,
        maximum_phyllochron_asymptote = 0.4421, # LTARa
        leaves_generic = 10, # GLN
    ),
    :Leaf => (
        maximum_elongation_rate = 4.70, # LER
        minimum_length_of_longest_leaf = 65.0, # LL
        # stay_green = , # SG
    ),
    :Carbon => (
# # Rm Yg
# 0.012 0.8
        maintenance_respiration_coefficient = 0.012, # Rm
        synthesis_efficiency = 0.8, # Yg
        partitioning_table = [
        # root leaf sheath scape bulb
          0.00 0.00   0.00  0.00 0.00 ; # seed garlic before germination
          0.35 0.30   0.25  0.00 0.10 ; # vegetative stage between germination and scape initiation
          0.15 0.15   0.10  0.25 0.35 ; # period between scape initiation and scape appearance
          0.05 0.10   0.00  0.35 0.50 ; # period after scape appearance before removal (scape stays intact)
          0.05 0.00   0.00  0.00 0.95 ; # period after scape removal (scape appeared and subsequently removed)
          0.00 0.00   0.00  0.00 0.00 ; # dead
        ],
    ),
)
KM = @config (KMSP, (
    :Phenology => (initial_leaves_at_harvest = 4,), # ILN
    :Leaf => (stay_green = 1.84,), # SG
    :Meta => (cultivar = :KM,),
))
SP = @config (KMSP, (
    :Phenology => (initial_leaves_at_harvest = 6,), # ILN
    :Leaf => (stay_green = 1.47,), # SG
    :Meta => (cultivar = :SP,),
))

CUH = @config (
# # LAT LONG ALT
# 47.66 122.29 20.0
    :Location => (
        latitude = 47.66, # LAT
        longitude = 122.29, #LONG
        altitude = 20.0, # ALT
    ),
# # CO2 timestep
# 390 60
    :Weather => (
        CO2 = 390, # CO2
    ),
    :Plant => (initial_planting_density = 55,), # PD0
)
CUH_2013 = @config (CUH, (
    :Weather => (
        store = Garlic.loadwea(Garlic.datapath("CUH/2013.wea"), tz),
    ),
    :Calendar => (
        init = ZonedDateTime(2013, 10, 30, tz), # Y1 bgn
        last = ZonedDateTime(2014, 7, 28, tz), #Y2 end
    ),
    :Meta => (
        year = 2013,
    )
))
CUH_2014 = @config (CUH, (
    :Weather => (
        store = Garlic.loadwea(Garlic.datapath("CUH/2014.wea"), tz),
    ),
    :Calendar => (
        # 2014.wea starts from 2014-09-01 01:00, not 00:00
        init = ZonedDateTime(2014, 9, 1, 1, tz), # Y1 bgn
        last = ZonedDateTime(2015, 7, 7, tz), #Y2 end
    ),
    :Meta => (
        year = 2014,
    )
))

P1 = @config :Meta => (; planting_group = 1)
P2 = @config :Meta => (; planting_group = 2)

CUH_2013_P1 = @config (CUH_2013, P1, (
    :Phenology => (
        storage_days = 122, # SD
        planting_date = ZonedDateTime(2013, 10, 30, tz), # Y1 sow
    ),
))
CUH_2013_P2 = @config (CUH_2013, P2, (
    :Phenology => (
        storage_days = 170, # SD
        planting_date = ZonedDateTime(2013, 12, 17, tz), # Y1 sow
    ),
))
CUH_2014_P1 = @config (CUH_2014, P1, (
    :Phenology => (
        storage_days = 93, # SD
        planting_date = ZonedDateTime(2014, 10, 1, tz), # Y1 sow
    ),
))
CUH_2014_P2 = @config (CUH_2014, P2, (
    :Phenology => (
        storage_days = 143, # SD
        planting_date = ZonedDateTime(2014, 11, 20, tz), # Y1 sow
    ),
))

KM_2013_P1_SR0 = @config (KM, CUH_2013_P1, (
    :Phenology => (
        emergence_date = ZonedDateTime(2013, 12, 29, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))
KM_2013_P2_SR0 = @config (KM, CUH_2013_P2, (
    :Phenology => (
        emergence_date = ZonedDateTime(2014, 1, 26, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))
KM_2014_P1_SR0 = @config (KM, CUH_2014_P1, (
    :Phenology => (
        emergence_date = ZonedDateTime(2014, 10, 26, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))
KM_2014_P2_SR0 = @config (KM, CUH_2014_P2, (
    :Phenology => (
        emergence_date = ZonedDateTime(2014, 12, 30, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))

SP_2013_P1_SR0 = @config (SP, CUH_2013_P1, (
    :Phenology => (
        emergence_date = ZonedDateTime(2013, 11, 14, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))
SP_2013_P2_SR0 = @config (SP, CUH_2013_P2, (
    :Phenology => (
        emergence_date = ZonedDateTime(2014, 1, 6, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))
SP_2014_P1_SR0 = @config (SP, CUH_2014_P1, (
    :Phenology => (
        emergence_date = ZonedDateTime(2014, 10, 6, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))
SP_2014_P2_SR0 = @config (SP, CUH_2014_P2, (
    :Phenology => (
        emergence_date = ZonedDateTime(2014, 11, 30, tz), # Y1 emg
        scape_removal_date = nothing, # Y2 SR
    ),
))

using CSV
using DataFrames
using DataFramesMeta
import Dates
loaddata(cv, y, p) = begin
    ps = CSV.File(Garlic.datapath("CUH/PhenologySummary.csv")) |> DataFrame |> unitfy
    @chain ps begin
        @subset(:cultivar .== cv, :year .== y, :planting_group .== p)
        @select(:DAP, :leaves)
    end
end

calibrate_LTAR(cv, y, p) = begin
    c = eval(Symbol("$(cv)_$(y)_P$(p)_SR0")) #HACK for now
    obs = loaddata(cv, y, p)
    f(s) = s.DAP' in obs.DAP && Dates.hour(s.calendar.time') == 12
    #r = simulate(Garlic.Model;
    calibrate(Garlic.Model, obs;
        config=c,
        stop="calendar.count",
        index=:DAP,
        target=:Leaves => :leaves_appeared,
        parameters=:Phenology => :LTARa_max => (0.01, 0.80),
        snap=f,
        optim=(:MaxSteps => 100,),
    )
end
#calibrate_LTAR(:KM, 2014, 2)

end
