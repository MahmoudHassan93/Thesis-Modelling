using Distributions, Random, Plots
function Model_particles()
    #initial parameters
    Nsteps = 9000 
    Pdensity  = 0.008
    Npopulations = 10000
    Lgrid = trunc(Int, sqrt(Npopulations/Pdensity))
    gapstep = trunc(Int, sqrt(1/Pdensity))
    probability = 0.3
    saferange = 2
    tinc  = 14
    dt    = 0.01 
    #plot parameters
    numberofhealthyy= Int64[]
    numberofinfectedd= Int64[]
    numberofrecoveredd= Int64[]
    numberofsickk= Int64[]
    dayss = Float32[]
    # end of plot parameters
    #representation of indiviual Person
    Person = [Dict("x" => 0,"y" => 0,"healthStatus" => 0,"color" => "white","timecounter" => 0) for i  ∈ 1:Npopulations]
    #initial important parameters
    healthyIndividuals = Int64[]  #list for healthy people # healthy individual index in Person array is stored here
    sickIndividuals = Int64[]     #list for sick people # sick individual index in Person array is stored here
    numberofhealthy = 0                  #number of healthy people
    numberofinfected = 0                 #number of infected people
    numberofrecovered = 0                #number of recovered people
    numberofsick = 0                     #number of sick people
    days = 0            
    #initialize population #color #healthStatus #timecounter #update healthyIndividuals list
    for ipop in 1:Npopulations              
        Person[ipop]["color"] = "white"     #update color for each individual
        Person[ipop]["healthStatus"] = 0    #update healthstatus healthy=0 infected=1 recovered=2
        Person[ipop]["timecounter"] = 0     #update timecounter to recover 0 for healthy 14=tinc for infected
        push!(healthyIndividuals,ipop)    #add index(number) of healthy individual to healthyIndividuals list
        numberofhealthy +=1              #update number of healthy people
    end        
    #initialize population position on the gride
    yincrement = 0
    for ipop in 2:Npopulations 
        Person[ipop]["x"] = Person[ipop-1]["x"] + gapstep 
        Person[ipop]["y"] += yincrement
        if (Person[ipop]["x"] + gapstep > Lgrid)
            Person[ipop]["x"] = 0
            yincrement += gapstep
            Person[ipop]["y"] = yincrement
        end            
    end
    #plot parameters initialization
    push!(numberofhealthyy,numberofhealthy)
    push!(numberofinfectedd,numberofinfected)
    push!(numberofrecoveredd,numberofrecovered)
    push!(numberofsickk,numberofsick)
    push!(dayss,days)
    #end plot parameters initialization
    # choose random percentage of people to get infected # in this case 1% = 0.01
    numberofsick = trunc(Int, 0.01*Npopulations)
    #loop through population to select the number of sick people and update their status
    for isick in 1:numberofsick
        Iindiv = rand(1:Npopulations)    #index of chosen individual to make sick #choose random
        #after choose, update individual data
        Person[Iindiv]["healthStatus"] = 1
        Person[Iindiv]["color"] = "red"
        Person[Iindiv]["timecounter"] = tinc
        if(Iindiv ∉ sickIndividuals)
            push!(sickIndividuals,Iindiv)
            deleteat!(healthyIndividuals, findall(x->x==Iindiv,healthyIndividuals))
            numberofhealthy -=1
            numberofinfected += 1
        end
    end
    
    #loop through number of steps
    for ist in 1:Nsteps
        #scatter([Person[i]["x"] for i in 1:Npopulations], [Person[i]["y"] for i in 1:Npopulations],legend=false, color = [Person[i]["color"] for i in 1:Npopulations])
        #scatter!((days,[numberofhealthy numberofinfected numberofrecovered numberofsick]),legend=false,color = [:blue :green :gold :red])
        #update plot parameters
        push!(numberofhealthyy,numberofhealthy)
        push!(numberofinfectedd,numberofinfected)
        push!(numberofrecoveredd,numberofrecovered)
        push!(numberofsickk,numberofsick)
        push!(dayss,days)
        #end of updating plot parameters
        # move every individual and calculate their distances
        for ipop in 1:Npopulations 
            temp = rand()
            if (temp <= 0.25)
                Person[ipop]["x"] += rand() # rand(0.3:0.1:1.5)  
            elseif (temp > 0.25) && (temp <=0.5)   
                Person[ipop]["x"] -= rand() # rand(0.3:0.1:1.5)
            elseif (temp > 0.5 ) && (temp <=0.75) 
                Person[ipop]["y"] += rand() # rand(0.3:0.1:1.5) 
            else
                Person[ipop]["y"] -= rand() # rand(0.3:0.1:1.5) 
            end  
            #add boundary conditions
            if (Person[ipop]["x"] < 0)       #check for left x position
                Person[ipop]["x"] = Lgrid
            end
            if (Person[ipop]["x"] > Lgrid)            #check for right x position
                Person[ipop]["x"] = 0
            end
            if (Person[ipop]["y"] < 0)            #check for up y position
                Person[ipop]["y"] = Lgrid
            end
            if (Person[ipop]["y"] > Lgrid)            #check for down y position
                Person[ipop]["y"] = 0
            end 
        end
        additionalSick = Int64[]
        for k in sickIndividuals
            Person[k]["timecounter"] -= dt
            for m in healthyIndividuals
                distance = sqrt(((abs(Person[k]["x"]-Person[m]["x"]))^2)+((abs(Person[k]["y"]-Person[m]["y"]))^2))
                #print("distance = ",distance,"\n")
                if(distance<saferange)
                    test = rand()
                    #print("test = ",test,"\n")
                    if(test <= probability)
                            #print("enter the infected section","\n")
                            Person[m]["healthStatus"] = 1
                            Person[m]["color"] = "red"
                            Person[m]["timecounter"] = tinc
                            push!(additionalSick,m)
                            deleteat!(healthyIndividuals, findall(x->x==m,healthyIndividuals))
                            numberofhealthy -=1
                            numberofinfected += 1
                            numberofsick+= 1
                            #print(numberofhealthy,"\n")
                            #print(numberofinfected,"\n")
                    end
                end
            end
            if (Person[k]["timecounter"] <=0)
                Person[k]["healthStatus"] = 2
                Person[k]["timecounter"] = 0
                Person[k]["color"] = "green"
                deleteat!(sickIndividuals, findall(x->x==k,sickIndividuals))
                numberofrecovered +=1
                numberofsick-= 1
            end
        end
        append!(sickIndividuals,additionalSick)
        days +=dt   
    end
    #p1=plot(dayss,numberofhealthyy,legend=false,color = :blue)
    #p2=plot(dayss,numberofinfectedd,color =:green, xlabel="Days", ylabel="Population",label = "Infected")
    #p3=plot(dayss,numberofrecoveredd,legend=false,color =  :gold )
    #p4=plot(dayss,numberofsickk,legend=false,color =  :red)
    #plot(p1,p2,p3,p4)
    plot((dayss,[numberofhealthyy numberofinfectedd numberofrecoveredd numberofsickk]),
       color = [:blue :green :gold :red],
       label = ["Healthy" "Infected" "Recovered" "Sick"],
       xlabel="Days",
       ylabel="Population" )
end
Model_particles()







 