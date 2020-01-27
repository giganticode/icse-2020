/*******************************************************************************
 * Copyright (c) 2009, 2011 Fabian Steeg. All rights reserved. This program and
 * the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * <p/>
 * Contributors: Fabian Steeg
 *******************************************************************************/
package org.eclipse.zest.tests;

import org.eclipse.zest.tests.cloudio.TagCloudTests;
import org.eclipse.zest.tests.cloudio.TagCloudViewerTests;
import org.eclipse.zest.tests.dot.DotExportSuite;
import org.eclipse.zest.tests.dot.DotImportSuite;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

/**
 * Main test suite for all headless tests.
 * 
 * @author Fabian Steeg (fsteeg)
 */
@RunWith(Suite.class)
@Suite.SuiteClasses({ GraphTests.class, GraphSelectionTests.class,
		GraphViewerTests.class, IFigureProviderTests.class,
		LayoutAlgorithmTests.class, DotExportSuite.class, DotImportSuite.class,
		TagCloudTests.class, TagCloudViewerTests.class })
public final class AllHeadlessTests {
}
