//
//  VenuesListPresenter.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 30.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation

struct VenuesListProps {
    let venues: [Venue]?
    let error: Error?
    let onReload: () -> Void
    let onFavorite: (Venue) -> Void
    let onAppear: () -> Void
    let onDisappear: () -> Void
}

protocol VenuesListRenderer: AnyObject {
    func render(props: VenuesListProps)
}

class VenuesListPresenter: Presenter {
    private let coordinateProvider: CoordinateProvider
    private let venueService: VenueService
    private let favoriteVenueRepository: FavoriteVenueRepository
    
    weak var renderer: VenuesListRenderer?
    
    private var coordinate: Coordinate?
    
    private var dtos: [VenueDto]?
    private var favorites: [FavoriteVenue]?
    
    init(coordinateProvider: CoordinateProvider,
         venueService: VenueService,
         favoriteVenueRepository: FavoriteVenueRepository) {
        self.coordinateProvider = coordinateProvider
        self.venueService = venueService
        self.favoriteVenueRepository = favoriteVenueRepository
        
        self.favoriteVenueRepository.delegate = self
        self.coordinateProvider.delegate = self
    }
    
    func start() {
        render(for: [], with: nil)
        favorites = favoriteVenueRepository.findAll()
    }
        
    private func render(for venues: [Venue]?, with error: Error?) {
        runOnMainThread { [weak self] in
            guard let self = self else { return }
            self.renderer?.render(props: self.buildProps(for: venues, with: error))
        }
    }
    
    private func buildProps(for venues: [Venue]?, with error: Error?) -> VenuesListProps {
        return VenuesListProps(venues: venues,
                           error: error,
                           onReload: onReload,
                           onFavorite: onFavorite(for:),
                           onAppear: onAppear,
                           onDisappear: onDisappear)
    }
    
    private func load(for coordinate: Coordinate) {
        venueService.getVenues(for: coordinate) { [weak self] venues, error in
            guard let self = self else { return }
    
            guard error == nil, let venues = venues else {
                self.render(for: nil, with: error)
                return
            }
    
            self.dtos = Array(venues.prefix(15))
            self.render(for: self.combine(dtos: self.dtos, favorites: self.favorites), with: nil)
        }
    }
    
    private func onReload() {
        guard let coordinate = coordinate else { return }
        load(for: coordinate)
    }
    
    private func onFavorite(for venue: Venue) {
        let favoriteVenue = FavoriteVenue(id: venue.id)
        if venue.favorite {
            favoriteVenueRepository.delete(item: favoriteVenue)
        } else {
            favoriteVenueRepository.insert(item: favoriteVenue)
        }
    }
    
    private func onAppear() {
        coordinateProvider.startUpdatingCoordinate()
    }
    
    private func onDisappear() {
        coordinateProvider.stopUpdateCoordinate()
    }
    
    private func combine(dtos: [VenueDto]?, favorites: [FavoriteVenue]?) -> [Venue]? {
        guard let dtos = dtos else { return nil }
        
        let favotiteIds = Set(favorites?.map { $0.id } ?? [])
        return dtos.map { Venue(from: $0, favorite: favotiteIds.contains($0.id)) }
    }
}

extension VenuesListPresenter: CoordinateProviderDelegate {
    func coordinateProvider(_ coordinateProvider: CoordinateProvider, didUpdateCoordinate coordinate: Coordinate) {
        self.coordinate = coordinate
        load(for: coordinate)
    }
}

extension VenuesListPresenter: FavoriteVenueRepositoryDelegate {
    func favoriteVenueRepositoryDidChange(_ favoriteVenueRepository: FavoriteVenueRepository) {
        favorites = favoriteVenueRepository.findAll()
        render(for: combine(dtos: self.dtos, favorites: self.favorites), with: nil)
    }
}

private extension Venue {
    init(from dto: VenueDto, favorite: Bool) {
        self.init(id: dto.id,
                  name: dto.name,
                  shortDescription: dto.shortDescription,
                  imageUrl: dto.imageUrl,
                  favorite: favorite)
    }
}

private func runOnMainThread(block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async { block() }
    }
}
