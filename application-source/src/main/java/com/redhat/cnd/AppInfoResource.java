package com.redhat.cnd;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.config.inject.ConfigProperty;


@Path("/app/info")
public class AppInfoResource {

    @ConfigProperty(name = "application.environment")
    private String environment;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String appInfo() {

        // TODO: Json with app info (version, environment,...) 
        return this.environment;
    }
}