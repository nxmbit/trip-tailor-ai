package com.ai.triptailor.response;

import java.util.List;

public class TravelPlanInfoPagingResponse {
    private List<TravelPlanInfoResponse> travelPlansInfos;
    private int page;
    private int pageSize;
    private int totalPages;
    private int totalItems;
    private boolean empty;

    public TravelPlanInfoPagingResponse(List<TravelPlanInfoResponse> travelPlansInfos, int pageSize, int page, int totalPages, int totalItems, boolean empty) {
        this.travelPlansInfos = travelPlansInfos;
        this.pageSize = pageSize;
        this.page = page;
        this.totalPages = totalPages;
        this.totalItems = totalItems;
        this.empty = empty;
    }

    public TravelPlanInfoPagingResponse() {
    }

    public List<TravelPlanInfoResponse> getTravelPlansInfos() {
        return travelPlansInfos;
    }

    public void setTravelPlans(List<TravelPlanInfoResponse> travelPlansInfos) {
        this.travelPlansInfos = travelPlansInfos;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }

    public int getTotalItems() {
        return totalItems;
    }

    public void setTotalItems(int totalItems) {
        this.totalItems = totalItems;
    }

    public boolean isEmpty() {
        return empty;
    }

    public void setEmpty(boolean empty) {
        this.empty = empty;
    }
}
