//
//  ViewController.swift
//  HealthKitTest
//
//  Created by Jonathan Dixon on 28/06/2016.
//  Copyright © 2016 Jonathan Dixon. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class ViewController: UIViewController
{

    @IBOutlet weak var stepCountLabel: UILabel!
    
    let healthKitStore = HKHealthStore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(checkAuthorization())
        {
            if(HKHealthStore.isHealthDataAvailable())
            {
                recentSteps() { steps, error in
                    DispatchQueue.main.async {
                        self.stepCountLabel.text = String(format:"%.0f", steps)
                    }
                }
                
                

            }
        }
    }
    
    func updateStepCount()
    {
        
    }

    func checkAuthorization() -> Bool
    {
        var isEnabled = true

        if HKHealthStore.isHealthDataAvailable()
        {
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!,
                HKObjectType.workoutType(),
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
            ]
            
            healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead, completion: { (success, error) in
                isEnabled = success
            })
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func recentSteps(completion: @escaping (Double, NSError?) -> () )
    {
        let healthKitTypesToRead = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)


        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: Calendar.Component.hour, value: -24, to: Date())
        
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date(), options: [])

        

        let query = HKSampleQuery(sampleType: healthKitTypesToRead!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            var distance: Double = 0
            var distanceInt:Int = 0
            
            if results != nil {
                if (results?.count)! > 0
                {
                    for result in results as! [HKQuantitySample]
                    {
                        if(result.device?.model == "iPhone")
                        {
                           
//                            steps += result.quantity.doubleValue(for: HKUnit.count())
                            //何メートル換算で距離を取得
                            distance += result.quantity.doubleValue(for: HKUnit.meter())
                            print(result.quantity.doubleValue(for: HKUnit.meter()))
                            distanceInt = Int(distance)
                            self.stepCountLabel.text = "\(distanceInt)"
                        }
                    }
                }
                
                
            }
            
            if error != nil {
                completion(steps, error as! NSError)
            }
            
        }
        
        healthKitStore.execute(query)
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

