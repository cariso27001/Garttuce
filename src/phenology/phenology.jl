include("stage.jl")
include("planting.jl")
include("emergence.jl")
include("germination.jl")
include("floralinitiation.jl")
include("leafinitiation.jl")
include("leafappearance.jl")
# include("bulbappearance.jl")
# include("scapegrowth.jl")
include("death.jl")

#TODO make a common class to be shared by Garlic and MAIZSIM
@system Phenology(
    Planting,
    Emergence,
    Germination,
    FloralInitiation,
    LeafInitiation,
    LeafAppearance,
    # BulbAppearance,
    # ScapeGrowth,
    # ScapeAppearance,
    # ScapeRemoval,
    # FlowerAppearance,
    # BulbilAppearance,
    Death
) begin
    calendar ~ ::Calendar(override)
    weather ~ ::Weather(override)
    sun ~ ::Sun(override)
    soil ~ ::Soil(override)

    planting_date ~ preserve::datetime(parameter)
    DAP(t0=planting_date, t=calendar.time): day_after_planting => (t - t0) ~ track::int(u"d", min=0, round=:floor)

    leaves_generic => 10 ~ preserve::int(parameter)
    leaves_potential(leaves_total) ~ track::int(min=leaves_generic)
    leaves_total(leaves_initiated) ~ track::int

    T(leaves_appeared, T_air=weather.T_air): temperature => begin
        if leaves_appeared < 9
            #FIXME soil module is not implemented yet
            #T = T_soil
            #HACK garlic model does not use soil temperature
            T = T_air
        else
            T = T_air
        end
        #FIXME T_cur doesn't go below zero, but is it fair assumption?
        #max(T, 0.0u"°C")
    end ~ track(u"°C")
    #growing_temperature(r="gst_recorder.rate") => r ~ track
    T_opt: optimal_temperature => 22.28 ~ preserve(u"°C", parameter)
    T_ceil: ceiling_temperature => 34.23 ~ preserve(u"°C", parameter)

    #TODO support species/cultivar specific temperature parameters (i.e. Tb => 8, Tx => 43.3)
    GD(context, T, Tb=4.0u"°C", Tx=40.0u"°C"): growing_degree ~ ::GrowingDegree
    BF(context, T, To=T_opt', Tx=T_ceil'): beta_function ~ ::BetaFunction
    Q10(context, T, To=T_opt'): q10_function ~ ::Q10Function

    # garlic

    #FIXME clear definition of bulb maturing
    #bulb_maturing(scape_removed, bulbil_appeared) => (scape_removed || bulbil_appeared) ~ flag

    # common

    # # GDDsum
    # gdd_after_emergence(emerged, r=gdd_recorder.rate) => begin
    #     #HACK tracker is reset when emergence is over
    #     emerged ? r : 0
    # end ~ track
    #
    # current_stage(emerged, dead) => begin
    #     if emerged
    #         "Emerged"
    #     elseif dead
    #         "Inactive"
    #     else
    #         "none"
    #     end
    # end ~ track::str

#     development_phase(germinated, floral_initiated, dead, scape_removed, scape_appeared) => begin
#         if !germinated
#             :seed
#         elseif !floral_initiated
#             :vegetative
#         elseif dead
#             :dead
#         elseif !scape_removed
#             if !scape_appeared
#                 :bulb_growth_before_scape_appearance
#             else
#                 :bulb_growth_after_scape_appearance
#             end
#         else
#             :bulb_growth_after_scape_removal
#         end
#     end ~ track::sym
# end

### Jim modification of development_phase
    development_phase(germinated, floral_initiated, dead) => begin
        if !germinated
            :seed
        elseif !floral_initiated
            :vegetative
        elseif dead
            :dead
        end
    end ~ track::sym
end

@system PhenologyController(Controller) begin
    calendar(context) ~ ::Calendar
    weather(context, calendar) ~ ::Weather
    sun(context, calendar, weather) ~ ::Sun
    soil(context) ~ ::Soil
    phenology(context, calendar, weather, sun, soil): p ~ ::Phenology
end

plot_pheno(v, d=300u"d") = begin
    o = (
        :Calendar => (:init => ZonedDateTime(2007, 9, 1, tz"Asia/Seoul")),
        :Weather => (:store => loadwea(datapath("2007.wea"), tz"Asia/Seoul")),
        :Phenology => (:planting_date => ZonedDateTime(2007, 11, 1, tz"Asia/Seoul")),
    )
    r = simulate(PhenologyController, stop=d, config=o, base=:phenology)
    visualize(r, :time, v)
end
