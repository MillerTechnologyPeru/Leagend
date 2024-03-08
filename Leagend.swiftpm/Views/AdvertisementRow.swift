//
//  LeagendAdvertisementRow.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/23.
//

import Foundation
import SwiftUI
import Bluetooth
import Leagend

struct LeagendAdvertisementRow: View {
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    let advertisement: LeagendAccessory.Advertisement
    
    var body: some View {
        StateView(
            advertisement: advertisement,
            information: store.accessoryInfo?[advertisement.type]
        )
    }
}

internal extension LeagendAdvertisementRow {
    
    struct StateView: View {
        
        let advertisement: LeagendAccessory.Advertisement
        
        let information: LeagendAccessoryInfo?
        
        var body: some View {
            HStack {
                // icon
                VStack {
                    if let information {
                        CachedAsyncImage(
                            url: URL(string: information.image),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }, placeholder: {
                                Image(systemName: information.symbol)
                            })
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
                .frame(width: 40)
                
                // Text
                VStack(alignment: .leading) {
                    Text(verbatim: advertisement.name)
                        .font(.title3)
                }
            }
            
        }
    }
}
/*
#if DEBUG
struct LeagendAdvertisementRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                LeagendAdvertisementRow(
                    LeagendAccessory.Advertisement.bt20(BT20.Advertisement)
                )
            }
        }
    }
}
#endif
*/
