module Internal
    import Core: MethodTable
    import Core.Compiler: MethodTableView, InternalMethodTable,
                          MethodMatchResult, MethodLookupResult, WorldRange
    struct StackedMethodTable{MTV<:MethodTableView} <: MethodTableView
        world::UInt
        mt::MethodTable
        parent::MTV
    end
    StackedMethodTable(world::UInt, mt::MethodTable) = StackedMethodTable(world, mt, InternalMethodTable(world))
    StackedMethodTable(world::UInt, mt::MethodTable, parent::MethodTable) = StackedMethodTable(world, mt, StackedMethodTable(world, parent))

    import Core.Compiler: findall, _findall, length, vcat, isempty, max, min, getindex
    function findall(@nospecialize(sig::Type), table::StackedMethodTable; limit::Int=-1)
        result = _findall(sig, table.mt, table.world, limit)
        result === nothing && return nothing
        nr = length(result)
        if nr ≥ 1 && getindex(result, nr).fully_covers
            # no need to fall back to the parent method view
            return MethodMatchResult(result, true)
        end

        parent_result = findall(sig, table.parent; limit)::Union{Nothing, MethodMatchResult}
        parent_result === nothing && return nothing

        overlayed = parent_result.overlayed | !isempty(result)
        parent_result = parent_result.matches::MethodLookupResult
        
        # merge the parent match results with the internal method table
        return MethodMatchResult(
        MethodLookupResult(
            vcat(result.matches, parent_result.matches),
            WorldRange(
                max(result.valid_worlds.min_world, parent_result.valid_worlds.min_world),
                min(result.valid_worlds.max_world, parent_result.valid_worlds.max_world)),
            result.ambig | parent_result.ambig),
        overlayed)
    end

    import Core.Compiler: isoverlayed
    isoverlayed(::StackedMethodTable) = true

    import Core.Compiler: findsup, _findsup
    function findsup(@nospecialize(sig::Type), table::StackedMethodTable)
        match, valid_worlds = _findsup(sig, table.mt, table.world)
        match !== nothing && return match, valid_worlds, true
        # look up in parent
        parent_match, parent_valid_worlds = findsup(sig, table.parent)
        return (
            parent_match,
            WorldRange(
                max(valid_worlds.min_world, parent_valid_worlds.min_world),
                min(valid_worlds.max_world, parent_valid_worlds.max_world)),
            false)
    end
end