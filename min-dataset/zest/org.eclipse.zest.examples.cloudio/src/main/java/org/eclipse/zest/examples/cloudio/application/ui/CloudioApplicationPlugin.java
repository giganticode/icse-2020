/*******************************************************************************
* Copyright (c) 2011 Stephan Schwiebert. All rights reserved. This program and
* the accompanying materials are made available under the terms of the Eclipse
* Public License v1.0 which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* <p/>
* Contributors: Stephan Schwiebert - initial API and implementation
*******************************************************************************/
package org.eclipse.zest.examples.cloudio.application.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;


/**
 * 
 * @author sschwieb
 *
 */
public class CloudioApplicationPlugin extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "org.eclipse.examples.zest.cloudio"; //$NON-NLS-1$

	// The shared instance
	private static CloudioApplicationPlugin plugin;
	
	/**
	 * The constructor
	 */
	public CloudioApplicationPlugin() {
	}

	/*
	 * (non-Javadoc)
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext)
	 */
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
	}

	/*
	 * (non-Javadoc)
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
	}

	/**
	 * Returns the shared instance
	 *
	 * @return the shared instance
	 */
	public static CloudioApplicationPlugin getDefault() {
		return plugin;
	}

}
