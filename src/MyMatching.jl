module MyMatching

export deferred_acceptance

function deferred_acceptance(m_prefs::Vector{Vector{Int}},f_prefs::Vector{Vector{Int}},caps::Vector{Int})
    m = length(m_prefs)
    n = length(f_prefs)
    prop_prefs = zeros(Int,n+1,m)
    resp_prefs = zeros(Int,m+1,n)
    
    for male in 1:m
        num = length(m_prefs[male])
        for p in 1:num
            prop_prefs[p,male] = m_prefs[male][p]
        end
    end
    for fem in 1:n
        numf = length(f_prefs[fem])
        for q in 1:numf
            resp_prefs[q,fem] = f_prefs[fem][q]
        end
    end

    prop_matches, resp_matches, indptr = deferred_acceptance(prop_prefs, resp_prefs, caps)

    return prop_matches,resp_matches,indptr
end

function deferred_acceptance(m_prefs::Vector{Vector{Int}},f_prefs::Vector{Vector{Int}})
    m = length(m_prefs)
    n = length(f_prefs)
    prop_prefs = zeros(Int,n+1,m)
    resp_prefs = zeros(Int,m+1,n)
    
    for male in 1:m
        num = length(m_prefs[male])
        for p in 1:num
            prop_prefs[p,male] = m_prefs[male][p]
        end
    end
    for fem in 1:n
        numf = length(f_prefs[fem])
        for q in 1:numf
            resp_prefs[q,fem] = f_prefs[fem][q]
        end
    end
    
    caps = ones(Int, size(resp_prefs, 2))
    prop_matches, resp_matches, indptr =
        deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end

function deferred_acceptance(prop_prefs::Matrix{Int},resp_prefs::Matrix{Int},caps)
    m = size(prop_prefs,2)
    n = size(resp_prefs,2)
    prop_matches = zeros(Int64,m)
    L = sum(caps)
    resp_matches = zeros(Int64,L)
        
    indptr = Array{Int64}(n+1)
    indptr[1] = 1
    for i in 1:n
        indptr[i+1] = indptr[i] + caps[i]
    end
    
    for fnum in 1:n
        zeropref = findfirst(resp_prefs[:,fnum],0)
        for wm in indptr[fnum]:indptr[fnum+1]-1
            resp_matches[wm] = zeropref
        end
    end
    
    next = 1
    next_m_approach = ones(Int64,m)


    while next == 1
        for h in 1:m
            next = 0
            if prop_matches[h] == 0
                d = prop_prefs[next_m_approach[h],h]
                if d == 0
                    prop_matches[h] = 0
                else
                    if next != 1
                        next =1
                    end
                    a = resp_matches[indptr[d]:indptr[d+1]-1]
                    c = maximum(a)
                    x = findfirst(resp_prefs[:,d],h)
                    if c > x && x != 0
                        prop_matches[h] = d
                        r = findfirst(a,c)
                        if resp_matches[indptr[d]-1+r] != findfirst(resp_prefs[:,d],0)
                            prop_matches[resp_prefs[c,d]] = 0
                            next_m_approach[resp_prefs[c,d]] += 1
                        end
                        resp_matches[indptr[d]-1+r] = x
                    else
                        next_m_approach[h] += 1
                    end
                end
            end
        end
    end
    
    for iss in 1:n
        for isss in indptr[iss]:indptr[iss+1]-1
            resp_matches[isss] = resp_prefs[resp_matches[isss],iss]
        end
    end

    return prop_matches,resp_matches,indptr
end

function deferred_acceptance(prop_prefs::Matrix{Int},resp_prefs::Matrix{Int})
    caps = ones(Int, size(resp_prefs, 2))
    prop_matches, resp_matches, indptr = deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end


end